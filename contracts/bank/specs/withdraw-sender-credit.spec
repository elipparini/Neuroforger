

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

 //       "withdraw-sender-credit": "after a non-reverting `withdraw(amount)`, the credit of `msg.sender` is decreased by `amount`.", 

abstract contracts[] cs;

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank(abstract constructor_params);
    }
    
    
    function test_withdraw_sender_credit_violation() public {

        abstract transaction[] txs;

        abstract uint256 amount;
        abstract address sender;
        
        uint256 credit_senderBefore = bank.credits(sender);


        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 credit_senderAfter = bank.credits(sender);

        assertNotEq(credit_senderBefore - amount, credit_senderAfter, "sender credit decreased by amount");
    }
}
