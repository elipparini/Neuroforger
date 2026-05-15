pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Concretization of `abstract contracts[] cs;`
contract Dummy {}

contract BankTest is Test {       
    address immutable bank_deployer;      
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        // Concretization of `abstract address bank_deployer;`
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    function test_deposit_assets_credit_violation() public {
        // Concretization of `abstract transaction[] txs;`
        vm.deal(address(0xB0B), 1 ether);

        // Concretization of `abstract uint256 msg_value;`
        uint256 msg_value = 2;
        // Concretization of `abstract address sender;`
        address sender = address(0xB0B);

        uint256 sender_creditsBefore = bank.credits(sender);

        vm.prank(sender);
        bank.deposit{value: msg_value}(); // should not revert 
	
        uint256 sender_creditsAfter = bank.credits(sender);

        assertNotEq(
            sender_creditsAfter,
            sender_creditsBefore + msg_value,
            "sender credits did increase by msg.value"
        );
    }
}