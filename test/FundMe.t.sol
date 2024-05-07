//SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/FundMe.s.sol";

contract TestFundMe is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    function setUp() external {
        //        fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //        console.log("DeployedFundMe", deployFundMe);
        vm.deal(USER, 10e18);
    }

    function testMinimumUSD() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testCheckMsgSenderIsOwner() public view {
        console.log("Message sender ", msg.sender);
        console.log("Fund Me owner", fundMe.getOwner());
        console.log("Test Contract", address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersion() public view {
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender);
        assertEq(amountFunded, 10e18);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function testAddFunderToArrayFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;
        assertEq(startingOwnerBalance + startingContractBalance, endingOwnerBalance);
        assertEq(endingContractBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            hoax(address(i), 10e18);
            fundMe.fund{value: 10e18}();
        }
        uint256 startOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 startContractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startOwnerBalance + startContractBalance == address(fundMe.getOwner()).balance);
    }

    function testCheaperCode()public {

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance,0);
    }
}
