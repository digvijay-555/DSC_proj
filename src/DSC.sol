// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC20Burnable, ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/*
* @title: DSC
* @author: Digvijay Deshmukh 
* @Collateral: Exogenous (ETH & BTC)
* @Minting: Algorithmic
* @Relative Stability: Pegged to USD
*
* @This is the contract meant to be governed by DSCEngine. This contract is just the ERC20 implementation of our stablecoin system.
*/
contract DSC is ERC20Burnable, Ownable {
    error DSC_MustBeMoreThanZero();
    error DSC_BurnAmountExceedsBalance();
    error DSC_NotZeroAddress();

    constructor() ERC20("MyDSC", "DSC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DSC_MustBeMoreThanZero();
        }
        if (_amount > balance) {
            revert DSC_BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(address _to, uint _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DSC_NotZeroAddress();
        }
        if (_amount <= 0) {
            revert DSC_MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
