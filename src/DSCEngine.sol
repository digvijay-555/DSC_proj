// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

import {DSC} from "./DSC.sol";
import {ReentrancyGuard} from "./ReentrancyGuard.sol";


/*
* @title: DSC
* @author: Digvijay Deshmukh 
* @Collateral: Exogenous (ETH & BTC)
* @Minting: Algorithmic
* @Relative Stability: Pegged to USD
*
* It is similar to DAI if DAI had no governance, no fees and was only backed by WETH abd WBTC.
*
*Our DSC system should always be "overcollateralized". AT no point, should the value of all collateral <= the $ backed value of all DSC.
*
* @The system is designed t be as minimal as possible, and have the tokens maintain a 1 token == $1 peg.
* @notice This contract is the core of the DSC System. It handles all the logic for mining and redeeming DSC, as well as depositing and withdrawing collateral.
* @notice This contract is very loosely based on the MakerDAO DSS (DAI) System.
*/

contract DSCEngine is ReentrancyGuard{

    /**ERRORS**/
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__NotAllowedToken();

    /**State Variables**/
    mapping(address token =>address priceFeed) private s_priceFeeds;
    DSC private immutable i_dsc;

    /**Modifier**/
    modifier moreThanZero(uint256 amount){
        if(amount==0){
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token){
        if(s_priceFeeds[token]==address(0)){
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    /**Constructor**/
    constructor(
        address[] memory tokenAddresses, 
        address[] memory priceFeedAddresses, 
        address dscAddress
    ) {
        //USD Price Feeds
        if(tokenAddresses.length != priceFeedAddresses.length){
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        for(uint256 i = 0; i<tokenAddresses.length; i++){
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DSC(dscAddress);
    }

    /**Functions**/
    function depositCollateralAndMintDsc() external{}

    /*
    *@param tokenCollateralAddress The address of the token to deposit
    *@param amountCollateral The amount of collateral to deposit
    */

    function depositCollateral(
        address tokenCollateralAddress, 
        uint256 amountCollateral
    ) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant{

    }

    function redeemCollateral() external{}

    function mintDsc() external{}

    function redeemCollateralForDsc() external{}

    function burnDsc() external{}

    function liquidate() external{}

    function getHealthFactor() external view{}
}