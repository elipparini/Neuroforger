pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Dummy {}

contract BankTest is Test {     
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank(1 ether);
    }

    function test_not_deposit_revert_violation() public {
        vm.deal(address(0xB0B), 1 ether);

        address user = address(0xABCD);
        
        vm.prank(user);
        uint256 msg_value = 0;

        vm.expectRevert();
        bank.deposit{value: msg_value}();
    }
}