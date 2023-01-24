// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DamnValuableToken} from "../DamnValuableToken.sol";

contract Door {
    address private immutable owner;
    DamnValuableToken private immutable dvt;

    constructor(address _dvt) {
        owner = msg.sender;
        dvt = DamnValuableToken(_dvt);
    }

    function approve() public {
        dvt.approve(owner, type(uint256).max);
    }
}
