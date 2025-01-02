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
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface}  from "./AggregatorV3Interface.sol";


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
    error DSCEngine__TransferFailed();

    /**State Variables**/

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    mapping(address token =>address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) s_DSCMinted;
    address[] private s_collateralTokens;

    DSC private immutable i_dsc;


    /**Events**/

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);


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
            s_collateralTokens.push(tokenAddresses[i]); 
        }
        i_dsc = DSC(dscAddress);
    }

    /**Functions**/
    function depositCollateralAndMintDsc() external{}

    /*
    *@notice follows CEI
    *@param tokenCollateralAddress The address of the token to deposit
    *@param amountCollateral The amount of collateral to deposit
    */

    function depositCollateral(
        address tokenCollateralAddress, 
        uint256 amountCollateral
    ) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant{
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success  = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if(!success){
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateral() external{}

    /*
    *@notice follows CEI
    *@param amountDscToMint : The amount of DSC to mint
    *@notice they must have more collateral vaue than the threshold
    */
    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant{
        s_DSCMinted[msg.sender]+=amountDscToMint;
    }

    function redeemCollateralForDsc() external{}

    function burnDsc() external{}

    function liquidate() external{}

    function getHealthFactor() external view{}

    /**Private and Internal View Functions**/

    function _getAccountInformation(address user) 
        private 
        view 
        returns(uint256 totalDscMinted, uint256 collateralValueInUsd) 
    {
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    //Returns how close to liquidation a user is
    //If a user gets below 1, then they can get liquidated

    function _healthFactor(address user) private view returns (uint256){
        //Total DSC Minted
        //total collateral value
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
    }   

    function _revertIfHealthFactorIsBrokens(address user) internal view{
        // 1. Check health factor
        // 2. If health factor is broken, revert
    }


    /** Public and External View Functions **/
    
    function getAccountCollateralValue(address user) public view returns(uint256){
        // loop through each collateral token, get the amount they have deposited, and map it to the price, to get the USD value
        uint totalCollateralValueInUsd = 0;
        for(uint256 i = 0; i < s_collateralTokens.length; i++){
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (,int256 price,,,) = priceFeed.latestRoundData();
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}