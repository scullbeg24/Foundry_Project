// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundMe} from "src/FundMe.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundFundMe, WithdrawFundMe} from "script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe; // State variable for the contract

    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

       assert(address(fundMe).balance == 0);
    }
}