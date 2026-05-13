

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

abstract contracts[] cs;

contract BankTest is Test {         
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank(abstract constructor_params);
    }
    
    
    function test_deposit_assets_credit_violation() public {

        abstract transaction[] txs;


        abstract uint256 msg_value;
        abstract address sender;
        uint256 sender_creditsBefore = bank.credits(sender);

        vm.prank(sender);
        bank.deposit{value: msg_value}(); // should not revert 
	
        uint256 sender_creditsAfter = bank.credits(sender);

        assertNotEq(sender_creditsAfter, sender_creditsBefore + msg_value, "sender credits did increase by msg.value");
    }
}
