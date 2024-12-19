// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CompactSwapDecoder {
    address constant _ETH = address(0);

    uint256 private constant addressListStart =
        80084422859880547211683076133703299733277748156566366325829078699459944778998;

    struct swapTokenInfo {
        address inputToken;
        uint256 inputAmount;
        address inputReceiver;
        address outputToken;
        uint256 outputQuote;
        uint256 outputMin;
        address outputReceiver;
    }

    function decodeCompactSwap(
        address _receiver,
        bytes calldata data
    ) public view returns (swapTokenInfo memory) {
        swapTokenInfo memory tokenInfo;

        address executor;
        uint32 referralCode;
        bytes memory pathDefinition;
        {
            address msgSender = _receiver;

            assembly {
                let dataOffset := add(data.offset, 4)
                let dataLength := sub(data.length, 4)

                function loadFromData(offset, pos) -> result {
                    result := calldataload(add(offset, pos))
                }

                function getAddress(offset, currPos) -> result, newPos {
                    let inputPos := shr(240, loadFromData(offset, currPos))
                    
                    switch inputPos
                    // Reserve the null address as a special case that can be specified with 2 null bytes
                    case 0x0000 {
                        result := 0
                        newPos := add(currPos, 2)
                    }
                    // This case means that the address is encoded in the calldata directly following the code
                    case 0x0001 {
                        let rawData := loadFromData(offset, add(currPos, 2))
                        result := shr(96, rawData)
                        newPos := add(currPos, 22)
                    }
                    // Otherwise we use the case to load in from the cached address list
                    default {
                        result := sload(add(addressListStart, sub(inputPos, 2)))
                        newPos := add(currPos, 2)
                    }
                }

                let result := 0
                let pos := 0

                // Load in the input and output token addresses
                result, pos := getAddress(dataOffset, pos)
                mstore(tokenInfo, result)

                // Load in the output token address
                result, pos := getAddress(dataOffset, pos)
                mstore(add(tokenInfo, 0x60), result)

                // Load in the input amount - a 0 byte means the full balance is to be used
                let inputAmountLength := shr(248, loadFromData(dataOffset, pos))
                pos := add(pos, 1)

                if inputAmountLength {
                    let rawAmount := loadFromData(dataOffset, pos)
                    let amount := shr(
                        mul(sub(32, inputAmountLength), 8),
                        rawAmount
                    )
                    mstore(add(tokenInfo, 0x20), amount)
                    pos := add(pos, inputAmountLength)
                }

                // Load in the quoted output amount
                let quoteAmountLength := shr(248, loadFromData(dataOffset, pos))
                pos := add(pos, 1)

                let outputQuote := shr(
                    mul(sub(32, quoteAmountLength), 8),
                    loadFromData(dataOffset, pos)
                )
                mstore(add(tokenInfo, 0x80), outputQuote)
                pos := add(pos, quoteAmountLength)

                // Load the slippage tolerance and use to get the minimum output amount
                {
                    let slippageTolerance := shr(232, loadFromData(dataOffset, pos))
                    let minOutput := div(
                        mul(outputQuote, sub(0xFFFFFF, slippageTolerance)),
                        0xFFFFFF
                    )
                    mstore(add(tokenInfo, 0xA0), minOutput)
                }
                pos := add(pos, 3)

                // Load in the executor address
                executor, pos := getAddress(dataOffset, pos)

                // Load in the destination to send the input to - Zero denotes the executor
                result, pos := getAddress(dataOffset, pos)
                if eq(result, 0) {
                    result := executor
                }
                mstore(add(tokenInfo, 0x40), result)

                // Load in the destination to send the output to - Zero denotes msg.sender
                result, pos := getAddress(dataOffset, pos)
                if eq(result, 0) {
                    result := msgSender
                }
                mstore(add(tokenInfo, 0xC0), result)

                // Load in the referralCode
                referralCode := shr(224, loadFromData(dataOffset, pos))
                pos := add(pos, 4)

                // Set the offset and size for the pathDefinition portion of the msg.data
                let pathLength := mul(shr(248, loadFromData(dataOffset, pos)), 32)
                let pathOffset := add(pos, 1)
                
                pathDefinition := mload(0x40)
                mstore(pathDefinition, pathLength)
                
                let i := 0
                for {} lt(i, pathLength) { i := add(i, 32) } {
                    mstore(
                        add(add(pathDefinition, 32), i),
                        loadFromData(dataOffset, add(pathOffset, i))
                    )
                }
                mstore(0x40, add(add(pathDefinition, 32), pathLength))
            }
        }

        return tokenInfo;
    }
}