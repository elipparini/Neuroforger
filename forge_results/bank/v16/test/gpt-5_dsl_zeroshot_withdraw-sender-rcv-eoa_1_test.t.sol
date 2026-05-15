pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Replace abstract contracts[] cs;
contract Dummy {}

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    function assertIsEOA(address who) internal view {
        uint32 size;
        assembly {
            size := extcodesize(who)
        }
        assertEq(size, 0, "address is not an EOA");
    }
    
    function test_withdraw_sender_credit_violation() public {
        // Replace abstract transaction[] txs;
        vm.deal(address(bank), 0);

        // Replace abstract uint256 amount;
        uint256 amount = 1;
        // Replace abstract address sender;
        address sender = address(0x1234);
        
        assertNotEq(sender, address(bank), "sender equal to bank");
        
        uint256 balance_senderBefore = sender.balance;

        // assert sender is an EOA
        assertIsEOA(sender);

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 balance_senderAfter = sender.balance;

        assertNotEq(balance_senderBefore + amount, balance_senderAfter, "sender balance increased by amount");
    }
}