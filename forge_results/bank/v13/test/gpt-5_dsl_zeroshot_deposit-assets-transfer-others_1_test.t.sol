pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Dummy0 {}

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_deposit_assets_transfer_others_violation() public {

        vm.deal(address(0xCAFE), 1 ether);

	    address user = address(0xBEEF);
        assertNotEq(user, address(bank), "user equal to bank");

        uint256 user_balanceBefore = user.balance;

        uint256 msg_value = 10; // > 1 wei to trigger owner transfer
        address sender = address(0xCAFE);
        vm.prank(sender);
        bank.deposit{value: msg_value}(); // should not revert 
	
        uint256 user_balanceAfter = user.balance;

        assertNotEq(sender, user, "user equal to sender");

        assertNotEq(user_balanceBefore, user_balanceAfter, "user balance did not change");
    }
}