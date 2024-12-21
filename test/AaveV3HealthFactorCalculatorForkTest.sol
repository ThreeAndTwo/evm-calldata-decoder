// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/aaveV3/calcHealthFactor.sol";

contract AaveV3HealthFactorCalculatorForkTest is Test {
    uint256 mainnetFork;

    // Prime Market
    address constant PRIME_POOL = 0x4e033931ad43597d96D6bcc25c280717730B58B1;
    address constant PRIME_USER = 0xd46B96d15ffF9b2B17e9c788086f3159bD0e8355;
    address constant PRIME_SUPPLY_ASSET =
        0xbf5495Efe5DB9ce00f80364C8B423567e58d2110; // ezETH
    address constant PRIME_BORROW_ASSET =
        0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0; // wstETH

    // Ethereum Market
    address constant CORE_POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address constant CORE_USER = 0x2a55EC3d1da74338F70067Ea808D2BC338586761;
    address constant COMPARE_USER = 0x163A5EC5e9C32238d075E2D829fE9fA87451e3b7;
    address constant ETH_SUPPLY_ASSET =
        0x9D39A5DE30e57443BfF2A8307A4256c8797A3497; // sUSDe
    address constant ETH_BORROW_ASSET =
        0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT

    function setUp() public {
        // Fork Ethereum mainnet
        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        uint256 BLOCK_NUMBER = vm.envUint("BLOCK_NUMBER");

        // Create and activate fork
        mainnetFork = vm.createFork(MAINNET_RPC_URL, BLOCK_NUMBER);
        vm.selectFork(mainnetFork);

        // Ensure fork is active
        require(vm.activeFork() == mainnetFork, "Fork not activated");
    }

    function test_PrimeMarket_NoChange() public view {
        (,,,,, uint256 currentHealthFactor) = IPool(PRIME_POOL).getUserAccountData(PRIME_USER);

        uint256 healthFactor = AaveV3HealthFactorCalculator.calcHealthFactor(
            PRIME_POOL,
            PRIME_USER,
            PRIME_SUPPLY_ASSET,
            PRIME_BORROW_ASSET,
            0, // unchanged
            0  // unchanged
        );

        assertApproxEqRel(
            healthFactor,
            currentHealthFactor,
            0.01e18,
            "Health factor calculation should match current value"
        );
    }

    function test_PrimeMarket_Supply100ezETH_Borrow1000wstETH() public view {
        uint8 supplyDecimals = IERC20(PRIME_SUPPLY_ASSET).decimals();
        uint8 borrowDecimals = IERC20(PRIME_BORROW_ASSET).decimals();

        // Calculate health factor after increasing collateral and debt
        uint256 healthFactor = AaveV3HealthFactorCalculator.calcHealthFactor(
            PRIME_POOL,
            PRIME_USER,
            PRIME_SUPPLY_ASSET,
            PRIME_BORROW_ASSET,
            int256(100 * (10 ** supplyDecimals)), // supply 100 ezETH
            int256(1000 * (10 ** borrowDecimals)) // borrow 1000 wstETH
        );
        assertEq(healthFactor, 1196012976122747280);
    }

    function test_PrimeMarket_Withdraw10ezETH_Repay100wstETH() public view {
        uint8 supplyDecimals = IERC20(PRIME_SUPPLY_ASSET).decimals();
        uint8 borrowDecimals = IERC20(PRIME_BORROW_ASSET).decimals();

        // Calculate health factor after increasing collateral and debt
        uint256 healthFactor = AaveV3HealthFactorCalculator.calcHealthFactor(
            PRIME_POOL,
            PRIME_USER,
            PRIME_SUPPLY_ASSET,
            PRIME_BORROW_ASSET,
            -int256(10 * (10 ** supplyDecimals)),    // withdraw 10 ezETH
            -int256(100 * (10 ** borrowDecimals))    // repay 100 wstETH
        );

        assertEq(healthFactor, 1271573206249060323);
    }

    // supply unchanged
    // borrow 3500 wstETH
    function test_PrimeMarket_Borrow3500WstETH() public view {
        uint8 borrowDecimals = IERC20(PRIME_BORROW_ASSET).decimals();
        // Calculate health factor after increasing collateral and debt
        uint256 healthFactor = AaveV3HealthFactorCalculator.calcHealthFactor(
            PRIME_POOL,
            PRIME_USER,
            PRIME_SUPPLY_ASSET,
            PRIME_BORROW_ASSET,
            0,    // withdraw 0 ezETH
            int256(3500 * (10 ** borrowDecimals))    // repay 3500 wstETH
        );
        assertEq(healthFactor, 1040933156218668326);
    }

    // repay 3500 wstETH
    function test_PrimeMarket_Repay3500WstETH() public view {
        uint8 borrowDecimals = IERC20(PRIME_BORROW_ASSET).decimals();

        uint256 healthFactor = AaveV3HealthFactorCalculator.calcHealthFactor(
            PRIME_POOL,
            PRIME_USER,
            PRIME_SUPPLY_ASSET,
            PRIME_BORROW_ASSET,
            0,    // withdraw 0 ezETH
            -int256(3500 * (10 ** borrowDecimals))    // repay 3500 wstETH
        );
        assertEq(healthFactor, 1609663544766281718);
    }

    function test_CoreMarket_NoChange() public view {
        (,,,,, uint256 currentHealthFactor) = IPool(CORE_POOL).getUserAccountData(CORE_USER);
        uint256 healthFactor = AaveV3HealthFactorCalculator.calcHealthFactor(
            CORE_POOL,
            CORE_USER,
            ETH_SUPPLY_ASSET,
            ETH_BORROW_ASSET,
            0,  // unchanged
            0   // unchanged
        );

        assertApproxEqRel(
            healthFactor,
            currentHealthFactor,
            0.01e18,
            "Health factor calculation should match current value"
        );
    }

    function test_CoreMarket_Supply100sUSDe_Borrow1000USDT() public view {
        uint8 supplyDecimals = IERC20(ETH_SUPPLY_ASSET).decimals();
        uint8 borrowDecimals = IERC20(ETH_BORROW_ASSET).decimals();

        (,,,,, uint256 currentHealthFactor) = IPool(CORE_POOL).getUserAccountData(CORE_USER);
        uint256 healthFactor = AaveV3HealthFactorCalculator.calcHealthFactor(
            CORE_POOL,
            CORE_USER,
            ETH_SUPPLY_ASSET,
            ETH_BORROW_ASSET,
            int256(100 * (10 ** supplyDecimals)),    // supply 100 sUSDe
            int256(1000 * (10 ** borrowDecimals))    // borrow 1000 USDT
        );

        assertApproxEqRel(
            healthFactor,
            currentHealthFactor,
            0.01e18,
            "Health factor calculation should match current value"
        );
    }

    function test_EdgeCases() public {
        uint8 supplyDecimals = IERC20(ETH_SUPPLY_ASSET).decimals();

        uint256 healthFactor = AaveV3HealthFactorCalculator.calcHealthFactor(
            CORE_POOL,
            COMPARE_USER,
            ETH_SUPPLY_ASSET,
            ETH_BORROW_ASSET,
            int256(100 * (10 ** supplyDecimals)),    // append 100 ezETH
            0                                         // no borrow
        );
        assertEq(healthFactor, type(uint256).max);

        vm.expectRevert("Insufficient collateral");
        AaveV3HealthFactorCalculator.calcHealthFactor(
            CORE_POOL,
            COMPARE_USER,
            ETH_SUPPLY_ASSET,
            ETH_BORROW_ASSET,
            -int256(999999 * (10 ** supplyDecimals)),  // try to remove more than available
            0
        );
    }

    function test_InsufficientDebt() public {
        uint8 borrowDecimals = IERC20(ETH_BORROW_ASSET).decimals();

        vm.expectRevert("Insufficient debt");
        AaveV3HealthFactorCalculator.calcHealthFactor(
            CORE_POOL,
            COMPARE_USER,
            ETH_SUPPLY_ASSET,
            ETH_BORROW_ASSET,
            0,
            -int256(9_999_999_999 * (10 ** borrowDecimals))  // try to repay more than borrowed
        );
    }
}
