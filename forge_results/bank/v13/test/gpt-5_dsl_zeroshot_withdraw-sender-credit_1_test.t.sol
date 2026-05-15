pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Attacker {
    Bank public bank;

    constructor(Bank _bank) payable {
        bank = _bank;
    }

    receive() external payable {
        // Reenter and deposit exactly what was received
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

        Attacker attacker = new Attacker(bank);
        vm.deal(address(attacker), 11);
        vm.prank(address(attacker));
        bank.deposit{value: 11}();

        uint256 amount = 10;
        address sender = address(attacker);
        
        uint256 credit_senderBefore = bank.credits(sender);

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 credit_senderAfter = bank.credits(sender);

        // credit_senderBefore = 10 (from 11 deposit -> 10 credit)
        // withdraw 10 -> credit becomes 0, then Attacker.receive reenters deposit{value:10}
        // deposit adds 9 credit (1 wei skim to owner), so credit_senderAfter = 9
        // credit_senderBefore - amount = 0, which != 9
        assertNotEq(credit_senderBefore - amount, credit_senderAfter, "sender credit decreased by amount");
    }
}