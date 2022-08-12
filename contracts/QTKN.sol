// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract QTKN is ERC20Upgradeable, OwnableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC20_init("QTKN", "QTKN");
        __Ownable_init();
    }

    function mint(address to, uint256 amount) public{
        _mint(to, amount);
    }

    function transfer(address owner,address to, uint256 amount) public virtual returns (bool) {
        _transfer(owner, to, amount);
        return true;
    }

}