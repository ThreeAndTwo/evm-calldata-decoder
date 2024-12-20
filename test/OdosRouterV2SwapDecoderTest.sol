// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/odos/OdosRouterV2SwapDecoder.sol";

contract OdosRouterV2SwapDecoderTest is Test {
    uint256 mainnetFork;
    
    function setUp() public {
        // Fork Ethereum mainnet
        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        mainnetFork = vm.createFork(MAINNET_RPC_URL, vm.envUint("BLOCK_NUMBER"));
        vm.selectFork(mainnetFork);
    }

    function testSwapCompactETH() public {
        address receiver = 0xf705dd58dd9DD6A5be319dF25282DEF5A1ce7A36;
        bytes memory data = hex"83bd37f9000000015de8ab7e27f6e7a1fff3e5b337584aa43961beef083782dace9d9000000ad39ded618035380000000147ae0001b28ca7e465c452ce4252598e0bc96aeba553cf8200000001f705dd58dd9dd6a5be319df25282def5a1ce7a3615b93efd030102040006010103d7259b720d000101020002420001030200ff000000000000c7cbff2a23d0926604f9352f65596e65729b8a17c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2f3a4b8efe3e3049f6bc71b47ccb7ce666542017900000000";
        
        OdosRouterV2SwapDecoder.swapCompactInfo memory result = OdosRouterV2SwapDecoder.swapCompact(receiver, data);

        assertEq(result.tokenInfo.inputToken, address(0), "Invalid input token");
        assertEq(result.tokenInfo.outputToken, 0x5DE8ab7E27f6E7A1fFf3E5B337584Aa43961BEeF, "Invalid output token");
        assertEq(result.tokenInfo.inputAmount, 4000000000000000000, "Invalid input amount");
        assertEq(result.tokenInfo.outputQuote, 999332571798893330694144, "Invalid output quote");
        assertEq(result.tokenInfo.outputMin, 994335913407263851907670, "Invalid output min");
        assertEq(result.tokenInfo.inputReceiver, 0xB28Ca7e465C452cE4252598e0Bc96Aeba553CF82, "Invalid input receiver");
        assertEq(result.tokenInfo.outputReceiver, receiver, "Invalid output receiver");
    }

    function testSwapCompactErc20() public {
        address receiver = 0x163A5EC5e9C32238d075E2D829fE9fA87451e3b7;
        bytes memory data = hex"83bd37f900019d39a5de30e57443bff2a8307a4256c8797a349700016b175474e89094c44da98b954eedeac495271d0f080de0b6b3a7640000080fdefee340f783800041890001B28Ca7e465C452cE4252598e0Bc96Aeba553CF8200000001163A5EC5e9C32238d075E2D829fE9fA87451e3b70000000104020204000701020203b819feef8f0fcdc268afe14162983a69f6bf179e000000000000000000000689020a00010001030203ff00000000000000000000000000126331661101057c3a5879ac6af3f30cac6c66e29d39a5de30e57443bff2a8307a4256c8797a3497a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000";
        
        OdosRouterV2SwapDecoder.swapCompactInfo memory result = OdosRouterV2SwapDecoder.swapCompact(receiver, data);

        assertEq(result.tokenInfo.inputToken, 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497, "Invalid input token");
        assertEq(result.tokenInfo.outputToken, 0x6B175474E89094C44Da98b954EedeAC495271d0F, "Invalid output token");
        assertEq(result.tokenInfo.inputAmount, 1000000000000000000, "Invalid input amount");
        assertEq(result.tokenInfo.outputQuote, 1143631607399678848, "Invalid output quote");
        assertEq(result.tokenInfo.outputMin, 1142487990447917520, "Invalid output min");
        assertEq(result.tokenInfo.inputReceiver, 0xB28Ca7e465C452cE4252598e0Bc96Aeba553CF82, "Invalid input receiver");
        assertEq(result.tokenInfo.outputReceiver, receiver, "Invalid output receiver");
    }

    function testSwap() public {
        bytes memory data = hex"3b635ce4000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb480000000000000000000000000000000000000000000000000000000df847580000000000000000000000000002950460e2b9529d0e00284a5fa2d7bdf3fa4d720000000000000000000000004c9edd5852cd905f086c759e8383e09bff1e68b3000000000000000000000000000000000000000000000cb7ee07d99b99000000000000000000000000000000000000000000000000000cb4ac833bf3400000000000000000000000000000001b648ade1ef219c87987cd60eba069a7faf1621f0000000000000000000000000000000000000000000000000000000000000140000000000000000000000000b28ca7e465c452ce4252598e0bc96aeba553cf8200000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000048010203000a01010001020100ff0000000000000000000000000000000000000002950460e2b9529d0e00284a5fa2d7bdf3fa4d72a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000000000000000000000000000000000000000000000000";
        
        OdosRouterV2SwapDecoder.swapCompactInfo memory result = OdosRouterV2SwapDecoder.swap(data);

        console.log("result.tokenInfo.inputToken", result.tokenInfo.inputToken);
        console.log("result.tokenInfo.outputToken", result.tokenInfo.outputToken);
        console.log("result.tokenInfo.inputAmount", result.tokenInfo.inputAmount);
        console.log("result.tokenInfo.outputQuote", result.tokenInfo.outputQuote);
        console.log("result.tokenInfo.outputMin", result.tokenInfo.outputMin);
        console.log("result.tokenInfo.inputReceiver", result.tokenInfo.inputReceiver);
        console.log("result.tokenInfo.outputReceiver", result.tokenInfo.outputReceiver);
        console.log("result.executor", result.executor);
        console.log("result.referralCode", result.referralCode);
        
        assertEq(result.tokenInfo.inputToken, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, "Invalid input token");
        assertEq(result.tokenInfo.outputToken, 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3, "Invalid output token");
        assertEq(result.tokenInfo.inputAmount, 60000000000  , "Invalid input amount");
        assertEq(result.tokenInfo.outputQuote, 60061303876892764405760, "Invalid output quote");
        assertEq(result.tokenInfo.outputMin, 60001242573015871389696, "Invalid output min");
        assertEq(result.tokenInfo.inputReceiver, 0x02950460E2b9529D0E00284A5fA2d7bDF3fA4d72, "Invalid input receiver");
        assertEq(result.tokenInfo.outputReceiver, 0x1b648ade1eF219C87987CD60eBa069A7FAf1621f, "Invalid output receiver");
        assertEq(result.executor, 0xB28Ca7e465C452cE4252598e0Bc96Aeba553CF82, "Invalid executor");
        assertEq(result.referralCode, 1, "Invalid referral code");
    }

    function testInvalidData() public {
        address receiver = address(this);
        bytes memory invalidData = hex"00";
        
        vm.expectRevert();
        OdosRouterV2SwapDecoder.swapCompact(receiver, invalidData);
    }
  
}   