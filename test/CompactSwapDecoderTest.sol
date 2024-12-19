// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/odos/swap_decoder.sol";

contract CompactSwapDecoderTest is Test {
    CompactSwapDecoder decoder;
    
    uint256 mainnetFork;
    
    function setUp() public {
        // Fork Ethereum mainnet
        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        mainnetFork = vm.createFork(MAINNET_RPC_URL, vm.envUint("BLOCK_NUMBER"));
        vm.selectFork(mainnetFork);
        
        // Deploy decoder
        decoder = new CompactSwapDecoder();
    }

    function testDecodeCompactSwapETH() public {
        // https://etherscan.io/tx/0x465fdaa343ee43ea304c5ca13ade1ffab68d5625fb5dc5c52865d44a5e988774
        address receiver = 0xf705dd58dd9DD6A5be319dF25282DEF5A1ce7A36;
        bytes memory data = hex"83bd37f9000000015de8ab7e27f6e7a1fff3e5b337584aa43961beef083782dace9d9000000ad39ded618035380000000147ae0001b28ca7e465c452ce4252598e0bc96aeba553cf8200000001f705dd58dd9dd6a5be319df25282def5a1ce7a3615b93efd030102040006010103d7259b720d000101020002420001030200ff000000000000c7cbff2a23d0926604f9352f65596e65729b8a17c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2f3a4b8efe3e3049f6bc71b47ccb7ce666542017900000000";
        CompactSwapDecoder.swapTokenInfo memory result = decoder.decodeCompactSwap(receiver, data);

        assertEq(result.inputToken, address(0), "Invalid input token");
        assertEq(result.outputToken, 0x5DE8ab7E27f6E7A1fFf3E5B337584Aa43961BEeF, "Invalid output token");
        assertEq(result.inputAmount, 4000000000000000000, "Invalid input amount");
        assertEq(result.outputQuote, 999332571798893330694144, "Invalid output quote");
        assertEq(result.outputMin, 994335913407263851907670, "Invalid output min");
        assertEq(result.inputReceiver, 0xB28Ca7e465C452cE4252598e0Bc96Aeba553CF82, "Invalid input receiver");
        assertEq(result.outputReceiver, receiver, "Invalid output receiver");
    }

    function testDecodeCompactSwapErc20() public {
        address receiver = 0x163A5EC5e9C32238d075E2D829fE9fA87451e3b7;
        bytes memory data = hex"83bd37f900019d39a5de30e57443bff2a8307a4256c8797a349700016b175474e89094c44da98b954eedeac495271d0f080de0b6b3a7640000080fdefee340f783800041890001B28Ca7e465C452cE4252598e0Bc96Aeba553CF8200000001163A5EC5e9C32238d075E2D829fE9fA87451e3b70000000104020204000701020203b819feef8f0fcdc268afe14162983a69f6bf179e000000000000000000000689020a00010001030203ff00000000000000000000000000126331661101057c3a5879ac6af3f30cac6c66e29d39a5de30e57443bff2a8307a4256c8797a3497a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000";
        CompactSwapDecoder.swapTokenInfo memory result = decoder.decodeCompactSwap(receiver, data);

        assertEq(result.inputToken, 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497, "Invalid input token");
        assertEq(result.outputToken, 0x6B175474E89094C44Da98b954EedeAC495271d0F, "Invalid output token");
        assertEq(result.inputAmount, 1000000000000000000, "Invalid input amount");
        assertEq(result.outputQuote, 1143631607399678848, "Invalid output quote");
        assertEq(result.outputMin, 1142487990447917520, "Invalid output min");
        assertEq(result.inputReceiver, 0xB28Ca7e465C452cE4252598e0Bc96Aeba553CF82, "Invalid input receiver");
        assertEq(result.outputReceiver, receiver, "Invalid output receiver");
    }

    function testDecodeCompactSwapWithZeroAddress() public {
        address receiver = address(this);
        bytes memory data = hex"0000000100000000000000000000000000000000000000000001080000000000000000000A080000000000000000000B030C000000000000040000000001FF01";

        CompactSwapDecoder.swapTokenInfo memory result = decoder.decodeCompactSwap(receiver, data);
        
        assertEq(result.inputToken, address(0), "Invalid input token");
        assertEq(result.outputToken, address(1), "Invalid output token");
    }

    // 测试无效数据
    function testDecodeCompactSwapWithInvalidData() public {
        address receiver = address(this);
        bytes memory data = hex"00";
        
        vm.expectRevert();
        decoder.decodeCompactSwap(receiver, data);
    }
}