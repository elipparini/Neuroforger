

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
    
    
    function test_withdraw_contract_balance_violation() public {

        abstract transaction[] txs;

        uint256 bank_balanceBefore = address(bank).balance;

        abstract uint256 amount;
        abstract address sender;
        assertNotEq(sender, address(bank), "sender equal to bank");

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 bank_balanceAfter = address(bank).balance;

        assertNotEq(bank_balanceBefore - amount, bank_balanceAfter, "bank balance decreased by amount");
    }
}
