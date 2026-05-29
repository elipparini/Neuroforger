pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Attacker contract that reenters and deposits the received ETH back into the Bank
contract Attacker {
    Bank public bank;
    constructor(Bank _bank) {
        bank = _bank;
    }
    receive() external payable {
        // Reenter and deposit the entire received amount, increasing credit by msg.value - 1
        bank.deposit{value: msg.value}();
    }
}

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_withdraw_sender_credit_violation() public {

        // Prepare attacker and initial state
        Attacker attacker = new Attacker(bank);
        vm.deal(address(attacker), 10);
        vm.prank(address(attacker));
        bank.deposit{value: 10}();

        uint256 amount = 5;
        address sender = address(attacker);
        
        uint256 credit_senderBefore = bank.credits(sender);

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 credit_senderAfter = bank.credits(sender);

        // Before: credit = 9
        // Withdraw 5: credit becomes 4, then reentrant deposit of 5 adds 4 => final credit = 8
        // 9 - 5 = 4 != 8 => assertion holds
        assertNotEq(credit_senderBefore - amount, credit_senderAfter, "sender credit decreased by amount");
    }
}