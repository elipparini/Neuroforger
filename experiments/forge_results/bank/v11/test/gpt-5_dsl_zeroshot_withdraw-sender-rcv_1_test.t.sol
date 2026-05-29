pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// A contract that forwards any received ETH to a sink, so its balance
// does not increase after receiving funds.
contract Forwarder {
    address payable public sink;
    constructor(address payable _sink) payable {
        sink = _sink;
    }
    receive() external payable {
        (bool s,) = sink.call{value: msg.value}("");
        require(s);
    }
}

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xA11CE);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_withdraw_sender_credit_violation() public {

        // Setup: deploy a Forwarder, fund it, and deposit into the bank
        Forwarder d = new Forwarder(payable(address(0xB0B)));
        vm.deal(address(d), 1 ether);
        vm.prank(address(d));
        bank.deposit{value: 1 ether}();

        uint256 amount = 1 ether;
        address sender = address(d);
        
        assertNotEq(sender, address(bank), "sender equal to bank");
        
        uint256 balance_senderBefore = sender.balance;

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 balance_senderAfter = sender.balance;

        // Forwarder forwards received ETH immediately; balance_after != before + amount
        assertNotEq(balance_senderBefore + amount, balance_senderAfter, "sender balance increased by amount");
    }
}