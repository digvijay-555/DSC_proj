// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        address _initialAccount,
        uint256 _initialBalance
    ) payable ERC20(_name, _symbol) {
        _mint(_initialAccount, _initialBalance);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
