

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

abstract contracts[] cs;

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank(abstract constructor_params);
    }
    
    
    function test_withdraw_assets_transfer_others_violation() public {

        abstract transaction[] txs;

	    abstract address user;
        assertNotEq(user, address(bank), "user equal to bank");

        uint256 user_balanceBefore = user.balance;


        abstract uint256 amount;
        abstract address sender;
        vm.prank(sender);
        bank.withdraw(amount); // should not revert 
	
        uint256 user_balanceAfter = user.balance;

        assertNotEq(sender, user, "user equal to sender");

        assertNotEq(user_balanceBefore, user_balanceAfter, "user balance did not change");
    }
}
