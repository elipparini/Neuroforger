pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";


contract BankTest is Test {       
    Bank immutable bank;
    
    constructor() {
        address bank_deployer = address(0xABCD);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_deposit_assets_credit_violation() public {

        vm.deal(address(0xBEEF), 100 ether);

        uint256 msg_value = 1 ether;
        address sender = address(0xBEEF);
        uint256 sender_creditsBefore = bank.credits(sender);

        vm.prank(sender);
        bank.deposit{value: msg_value}(); // should not revert 
	
        uint256 sender_creditsAfter = bank.credits(sender);

        assertNotEq(sender_creditsAfter, sender_creditsBefore + msg_value, "sender credits did increase by msg.value");
    }
}