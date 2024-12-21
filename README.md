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

### DEX
  #### KyberSwap V2 Decoder Methods
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

  #### Odos Router V2 Decoder Methods
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

  #### Common Utilities
  - Token path validation
  - Amount validation
  - Fee calculation helpers
  - Gas usage optimization


### LOAN
  #### AaveV3 Health Factor Calculator Methods
  - `calcHealthFactor(address lendingPool, address user, address supplyAsset, address borrowAsset, int256 appendSupply, int256 appendBorrow)`: Calculate health factor with hypothetical changes
    - Returns: uint256 (health factor scaled by 1e18)
    - Parameters:
      - `lendingPool`: Aave V3 lending pool address
      - `user`: User address to check
      - `supplyAsset`: Supply token address
      - `borrowAsset`: Borrow token address
      - `appendSupply`: Amount to add/subtract from supply (negative for withdrawal)
      - `appendBorrow`: Amount to add/subtract from borrow (negative for repayment)
    - Health Factor Formula:
      - `HF = (Total Collateral Value * Liquidation Threshold) / Total Borrow Value`
      - Returns max uint256 if total debt is zero

  - `getAssetsData(address lendingPool, address supplyAsset, address borrowAsset, int256 appendSupply, int256 appendBorrow)`: Get asset prices and decimals
    - Returns: (supply AssetData, borrow AssetData)
    - Uses Aave's price oracle for real-time pricing

  - `calculateAssetValue(int256 amount, uint256 assetPrice, uint8 decimals)`: Convert token amounts to USD value
    - Returns: uint256 (USD value in base units)
    - Handles both positive and negative amounts

  #### Common Features
  - Real-time price oracle integration
  - Decimal normalization
  - Checked math operations
  - Error handling for insufficient balances

# TODO

- [ ] L2 Integration Priority by Kyberswap / ODOS
- [ ] Add support for multi-collateral health factor calculation
