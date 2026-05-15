pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

//       "withdraw-sender-rcv-EOA": "after a non-reverting `withdraw(amount)` originated by an EOA, the ETH balance of the `msg.sender` is increased by `amount` wei."

contract Dummy {}

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xD1);
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

        vm.deal(address(0xB0B), 3 ether);
        vm.prank(address(0xB0B));
        bank.deposit{value: 2 ether}();

        uint256 amount = 1 ether;
        address sender = address(0xB0B);
        
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