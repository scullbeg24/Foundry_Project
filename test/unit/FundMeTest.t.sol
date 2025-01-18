// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";



contract FundMeTest is Test {
    FundMe fundMe; // State variable for the contract

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        // Deploy the FundMe contract with the required price feed address
            
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        }   

        function testMinimunDollarIsFive() public view {
           assertEq(fundMe.MINIMUM_USD(), 5e18);
        }

        function testOwnerIsMsgSender() public view {
            console.log(fundMe.i_owner());
            console.log(msg.sender);
            assertEq(fundMe.getOwner(), (msg.sender));
       }

        function testPriceFeedVersionIsAccurate() public {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        }

        function testFundFailsWithoutEnoughEth() public {
            vm.expectRevert(); // hye, the next line should revert!
            // assert(this tx fails/reverts)
            fundMe.fund(); //send 0 value

        }

        function testFundUpdatesFundedDataStructure() public {
            vm.prank(USER); // The next tx will be sent by USER
            fundMe.fund{value: SEND_VALUE}();
            uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
            assertEq(amountFunded, SEND_VALUE);
        }

        function testAddsFunderToArrayOfFunders() public{
            vm.prank(USER);
            fundMe.fund{value: SEND_VALUE}();

            address funder = fundMe.getFunder(0);
            assertEq(funder, USER);
        }

        modifier funded(){
            vm.prank(USER);
            fundMe.fund{value: SEND_VALUE}();
            _;
        }

        function testOnlyOwnerCanWithdraw() public funded {
            vm.prank(USER);
            vm.expectRevert();
            fundMe.withdraw();
        }

        function testWithdrawWithASingleFunder () public funded {
            //Arrange
            uint256 startingOwnerBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;

            //Act
            // uint256 gasStart = gasleft();
            //vm.txGasPrice(GAS_PRICE);
            vm.prank(fundMe.getOwner());
            fundMe.withdraw(); //should have spent gas?
            //uint256 gasEnd = gasleft();
            //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
            //console.log(gasUsed);

            //Assert
            uint256 endingOwnerBalance = fundMe.getOwner().balance;
            uint256 endingFundMeBalance = address(fundMe).balance;
            assertEq(endingFundMeBalance, 0);
            assertEq(
                startingFundMeBalance + startingOwnerBalance,
                endingOwnerBalance
            );
        }
        function testWithdrawFromMultipleFunders() public funded {
            //Arrange
            uint160 numberOfFunders = 10; // if you want use numners to generate addresses must be uint160
            uint160 startingFunderIndex = 1;
            for( uint160 i = startingFunderIndex; i < numberOfFunders; i++){
                // vm.prank new address
                // vm. deal new address
                // address ()
                hoax(address(i),SEND_VALUE);
                fundMe.fund{value: SEND_VALUE}();
                // fund the fundMe
            }
            //Act
            uint256 startingOwnerBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;

            vm.startPrank(fundMe.getOwner());
            fundMe.withdraw();
             vm.stopPrank();

             //Assert
             assert(address(fundMe).balance == 0);
             assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        }

         function testWithdrawFromMultipleFundersCheaper() public funded {
            //Arrange
            uint160 numberOfFunders = 10; // if you want use numners to generate addresses must be uint160
            uint160 startingFunderIndex = 1;
            for( uint160 i = startingFunderIndex; i < numberOfFunders; i++){
                // vm.prank new address
                // vm. deal new address
                // address ()
                hoax(address(i),SEND_VALUE);
                fundMe.fund{value: SEND_VALUE}();
                // fund the fundMe
            }
            //Act
            uint256 startingOwnerBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;

            vm.startPrank(fundMe.getOwner());
            fundMe.cheaperWithdraw();
             vm.stopPrank();

             //Assert
             assert(address(fundMe).balance == 0);
             assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        }
        
} 

