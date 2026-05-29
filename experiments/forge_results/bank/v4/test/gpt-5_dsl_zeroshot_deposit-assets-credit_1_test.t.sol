pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Dummy {}

contract BankTest is Test {       
    address immutable bank_deployer;      
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_deposit_assets_credit_violation() public {

        vm.deal(address(0xA11CE), 1 ether);

        uint256 msg_value = 1; // 1 wei
        address sender = address(0xA11CE);
        uint256 sender_creditsBefore = bank.credits(sender);

        vm.prank(sender);
        bank.deposit{value: msg_value}(); // should not revert 
	
        uint256 sender_creditsAfter = bank.credits(sender);

        assertNotEq(sender_creditsAfter, sender_creditsBefore + msg_value, "sender credits did increase by msg.value");
    }
}