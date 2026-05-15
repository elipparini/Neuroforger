

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

 //              "withdraw-sender-rcv": "after a non-reverting `withdraw(amount)`, the ETH balance of `msg.sender` is increased by `amount` wei.",

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
        
        assertNotEq(sender, address(bank), "sender equal to bank");
        
        uint256 balance_senderBefore = sender.balance;


        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 balance_senderAfter = sender.balance;

        assertNotEq(balance_senderBefore + amount, balance_senderAfter, "sender balance increased by amount");
    }
}
