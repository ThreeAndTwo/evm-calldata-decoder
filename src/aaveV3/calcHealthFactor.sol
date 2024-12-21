// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// lendingPool -> ADDRESSES_PROVIDER -> getPriceOracle()
// getPriceOracle -> getAssetPrice / getAssetsPrices -> Get asset prices

// After getting asset prices,
// Given new supplyBalance and borrowBalance
// Calculate health factor according to the formula
// Health Factor = (Total Collateral Value * Weighted Average Liquidation Threshold) / Total Borrow Value


interface IPool {
    function ADDRESSES_PROVIDER() external view returns (address);
    function getUserAccountData(
        address user
    )
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}

interface IPoolAddressesProvider {
    function getPriceOracle() external view returns (address);
}

interface IPriceOracle {
    function getAssetPrice(address asset) external view returns (uint256);
    function getAssetsPrices(
        address[] calldata assets
    ) external view returns (uint256[] memory);
}

interface IERC20 {
    function decimals() external view returns (uint8);
}

library AaveV3HealthFactorCalculator {
    string public constant NAME = "calcHealthFactorAaveV3";

    struct AssetData {
        uint256 price;
        uint8 decimals;
        uint256 valueChange;
    }

    struct AccountData {
        uint256 totalCollateralBase;
        uint256 totalDebtBase;
        uint256 currentLiquidationThreshold;
    }

    function calcHealthFactor(
        address lendingPool,
        address user,
        address supplyAsset,
        address borrowAsset,
        int256 appendSupply,
        int256 appendBorrow
    ) public view returns (uint256) {
        // 1. Get current user account data
        AccountData memory account;
        {
            (
                account.totalCollateralBase,
                account.totalDebtBase, // availableBorrowsBase
                ,
                account.currentLiquidationThreshold, // ltv
                ,

            ) = IPool(lendingPool).getUserAccountData(user);
        }

        // 2. Calculate asset value changes
        (AssetData memory supply, AssetData memory borrow) = getAssetsData(
            lendingPool,
            supplyAsset,
            borrowAsset,
            appendSupply,
            appendBorrow
        );

        // 3. Calculate new totals values for collateral and debt
        (uint256 newTotalCollateral, uint256 newTotalDebt) = calculateNewTotals( // 改为 uint256
            account,
            supply.valueChange,
            borrow.valueChange,
            appendSupply,
            appendBorrow
        );

        // 4. Calculate health factor
        if (newTotalDebt == 0) {
            return type(uint256).max;
        }

        return
            (1e18 * newTotalCollateral * account.currentLiquidationThreshold) /
            newTotalDebt /
            1e4;
    }

    function calculateNewTotals(
        AccountData memory account,
        uint256 supplyValueChange,
        uint256 borrowValueChange,
        int256 appendSupply,
        int256 appendBorrow
    ) internal pure returns (uint256 newTotalCollateral, uint256 newTotalDebt) {
        // Handle collateral changes
        if (appendSupply >= 0) {
            newTotalCollateral =
                account.totalCollateralBase +
                supplyValueChange;
        } else {
            require(
                account.totalCollateralBase >= supplyValueChange,
                "Insufficient collateral"
            );
            newTotalCollateral =
                account.totalCollateralBase -
                supplyValueChange;
        }

        // Handle debt changes
        if (appendBorrow >= 0) {
            newTotalDebt = account.totalDebtBase + borrowValueChange;
        } else {
            require(
                account.totalDebtBase >= borrowValueChange,
                "Insufficient debt"
            );
            newTotalDebt = account.totalDebtBase - borrowValueChange;
        }
    }

    function getAssetsData(
        address lendingPool,
        address supplyAsset,
        address borrowAsset,
        int256 appendSupply,
        int256 appendBorrow
    ) internal view returns (AssetData memory supply, AssetData memory borrow) {
        IPoolAddressesProvider provider = IPoolAddressesProvider(
            IPool(lendingPool).ADDRESSES_PROVIDER()
        );

        IPriceOracle oracle = IPriceOracle(provider.getPriceOracle());
        address[] memory assets = new address[](2);
        assets[0] = supplyAsset;
        assets[1] = borrowAsset;
        uint256[] memory prices = oracle.getAssetsPrices(assets);

        supply.price = prices[0];
        supply.decimals = IERC20(supplyAsset).decimals();
        supply.valueChange = calculateAssetValue(
            appendSupply,
            supply.price,
            supply.decimals
        );

        // Set borrow asset data
        borrow.price = prices[1];
        borrow.decimals = IERC20(borrowAsset).decimals();
        borrow.valueChange = calculateAssetValue(
            appendBorrow,
            borrow.price,
            borrow.decimals
        );
    }

    function calculateAssetValue(
        int256 amount,
        uint256 assetPrice,
        uint8 decimals
    ) internal pure returns (uint256) {
        if (amount == 0) return 0;

        // Only calculate absolute value, handle sign in calculateNewTotals
        uint256 absAmount = amount < 0 ? uint256(-amount) : uint256(amount);
        return (absAmount * assetPrice) / (10 ** decimals);
    }
}
