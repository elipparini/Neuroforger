pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Contract that forwards any received ETH to a recipient in its receive() hook
contract ForwarderOnReceive {
    address payable public recipient;
    constructor(address payable _recipient) {
        recipient = _recipient;
    }
    receive() external payable {
        recipient.transfer(msg.value);
    }
}

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xB0B);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_withdraw_sender_credit_violation() public {

        // Set up: deploy forwarding sender, fund it, and deposit into the bank
        ForwarderOnReceive f = new ForwarderOnReceive(payable(address(0xBEEF)));
        vm.deal(address(f), 1 ether);
        vm.prank(address(f));
        bank.deposit{value: 1 ether}();

        uint256 amount = 1 ether;
        address sender = address(f);
        
        assertNotEq(sender, address(bank), "sender equal to bank");
        
        uint256 balance_senderBefore = sender.balance;

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 balance_senderAfter = sender.balance;

        // The forwarding receive() causes sender's final balance not to increase by amount
        assertNotEq(balance_senderBefore + amount, balance_senderAfter, "sender balance increased by amount");
    }
}