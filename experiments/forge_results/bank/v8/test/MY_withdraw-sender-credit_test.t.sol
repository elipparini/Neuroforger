pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

 //       "withdraw-sender-credit": "after a non-reverting `withdraw(amount)`, the credit of `msg.sender` is decreased by `amount`.", 

// Attacker contract: on receive, re-deposits 1 ether into the Bank
contract Attacker {
    Bank public bank;
    constructor(Bank _bank) payable {
        bank = _bank;
    }
    receive() external payable {
        // Re-enter the bank by depositing 1 ether from the received funds
        bank.deposit{value: 1 ether}();
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

        // Deploy attacker, fund it, and make the initial deposit
        Attacker a = new Attacker(bank);
        vm.deal(address(a), 6 ether);
        vm.prank(address(a));
        bank.deposit{value: 5 ether}();

        uint256 amount = 5 ether;
        address sender = address(a);
        
        uint256 credit_senderBefore = bank.credits(sender);


        vm.prank(sender);
        bank.withdraw(amount); // should not revert
    
        uint256 credit_senderAfter = bank.credits(sender);

        assertNotEq(credit_senderBefore - amount, credit_senderAfter, "sender credit decreased by amount");
    }
}
