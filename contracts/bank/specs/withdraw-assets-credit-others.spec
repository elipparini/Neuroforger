

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// property: after a successful withdraw(amount), the balances of any user but the sender are preserved.

abstract contracts[] cs;

contract BankTest is Test {         
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank(abstract constructor_params);
    }
    
    
    function test_withdraw_assets_credit_others_violation() public {

        abstract transaction[] txs;

	    abstract address user;
        uint256 user_creditsBefore = bank.credits(user);

        abstract uint256 amount;
        abstract address sender;
        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 user_creditsAfter = bank.credits(user);

        assertNotEq(sender, user, "user equal to sender");

        assertNotEq(user_creditsBefore, user_creditsAfter, "user credits did not change");
    }
}
