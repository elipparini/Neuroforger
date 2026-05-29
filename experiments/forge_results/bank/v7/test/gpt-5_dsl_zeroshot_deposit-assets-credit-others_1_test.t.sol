pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Dummy {}

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xABCD);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_deposit_assets_credit_others_violation() public {

        vm.deal(address(0xBEEF), 1 ether);

	    address user = bank.owner();
        uint256 user_creditsBefore = bank.credits(user);

        uint256 msg_value = 1;
        address sender = address(0xBEEF);
        vm.prank(sender);
        bank.deposit{value: msg_value}(); // should not revert 
	
        uint256 user_creditsAfter = bank.credits(user);

        assertNotEq(sender, user, "user equal to sender");

        assertNotEq(user_creditsBefore, user_creditsAfter, "user credits did not change");
    }
}