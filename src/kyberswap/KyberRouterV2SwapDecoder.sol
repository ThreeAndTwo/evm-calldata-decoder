// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library KyberRouterV2SwapDecoder {
    // KyberSwap Router V2 contract address
    address public constant KYBERSWAP_V2_ROUTER =
        0x6131B5fae19EA4f9D964eAc0408E4408b66337b5;

    struct SwapDescriptionV2 {
        address srcToken;
        address dstToken;
        address[] srcReceivers; // transfer src token to these addresses, default
        uint256[] srcAmounts;
        address[] feeReceivers;
        uint256[] feeAmounts;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

    /// @dev  use for swapGeneric and swap to avoid stack too deep
    struct SwapExecutionParams {
        address callTarget; // call this address
        address approveTarget; // approve this address if _APPROVE_FUND set
        bytes targetData;
        SwapDescriptionV2 desc;
        bytes clientData;
    }

    /// @dev decode swap function call data
    /// @param data call data
    function swap(
        bytes calldata data
    ) public pure returns (SwapExecutionParams memory params) {
        (params) = abi.decode(data[4:], (SwapExecutionParams));
    }

    /// @dev decode swapSimpleMode function call data
    /// @param data call data
    function swapSimpleMode(
        bytes calldata data
    )
        public
        pure
        returns (
            address caller,
            SwapDescriptionV2 memory desc,
            bytes memory executorData,
            bytes memory clientData
        )
    {
        (caller, desc, executorData, clientData) = abi.decode(
            data[4:],
            (address, SwapDescriptionV2, bytes, bytes)
        );
    }
}
