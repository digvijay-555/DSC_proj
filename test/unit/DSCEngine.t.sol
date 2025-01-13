// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DSC} from "../../src/DSC.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "../../extra_contracts/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DSC dsc;
    DSCEngine dsce;
    HelperConfig config;
    address weth;
    address ethUsdPriceFeed;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (ethUsdPriceFeed, , weth, , ) = config.activeNetworkConfig();

        // Mint some tokens for the test user
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    ///////////////
    // Price Tests
    ///////////////

    function testGetUsdValue() public {
        // Arrange
        uint256 ethAmount = 15e18; // 15 ETH
        uint256 expectedUsd = 30000e18; // Assuming 1 ETH = $2000, so 15 ETH = $30,000

        // Act
        uint256 actualUsd = dsce.getUsdValue(weth, ethAmount);

        // Assert
        assertEq(expectedUsd, actualUsd, "The USD value returned does not match the expected value.");
    }

    /////////////////////////////
    // depositCollateral Tests //
    /////////////////////////////

    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER); // Start acting as USER
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);

        vm.expectRevert(); // Expect a revert
        dsce.depositCollateral(weth, 0); // Attempt to deposit 0 collateral
        vm.stopPrank(); // Stop acting as USER
    }

    // Additional tests can be added below
}
