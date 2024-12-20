## EVM Calldata decoder helper
A Solidity library for decoding DeFi swap transactions from popular DEX protocols.

## Overview

This project provides decoder libraries for parsing and extracting swap transaction data from various decentralized exchanges (DEXs) and L2 networks. The library aims to standardize the decoding process across different protocols and layers.

## Supported Protocols

### Layer 1 DEXs
- KyberSwap V2
- Odos Router V2

### Layer 2 Networks (Planned)
- Arbitrum
- Optimism
- zkSync Era
- Polygon zkEVM

## Features

### KyberSwap V2 Decoder Methods
- `decode(bytes calldata inputData)`: Decode swap transaction data
  - Returns: (caller, swapDescription, executorData, clientData)
  - Parameters:
    - `inputData`: Raw transaction input data
  - SwapDescription contains:
    - `srcToken`: Source token address
    - `dstToken`: Destination token address
    - `srcReceiver`: Source token receiver
    - `dstReceiver`: Destination token receiver
    - `amount`: Amount of source tokens
    - `minReturnAmount`: Minimum amount of destination tokens
    - `feeBps`: Fee in basis points
    
- `decodeSwapExecutorData(bytes memory _executorData)`: Decode executor data
  - Returns: (tokens, data)
  - Parameters:
    - `_executorData`: Executor-specific data
  - Used for complex swaps with multiple hops

### Odos Router V2 Decoder Methods
- `swap(bytes calldata data)`: Decode swap transaction data
  - Returns: swapCompactInfo struct
  - Parameters:
    - `data`: Raw transaction input data
  - SwapCompactInfo contains:
    - `tokenIn`: Input token address
    - `amountIn`: Input amount
    - `tokenOut`: Output token address
    - `amountOutMin`: Minimum output amount
    - `executor`: Swap executor address
    
- `swapSimple(bytes calldata data)`: Decode simple swap data
  - Returns: swapSimpleCompactInfo struct
  - Parameters:
    - `data`: Raw transaction input data
  - Used for direct token-to-token swaps

### Common Utilities
- Token path validation
- Amount validation
- Fee calculation helpers
- Gas usage optimization


# TODO
    [ ] L2 Integration Priority by Kyberswap / ODOS