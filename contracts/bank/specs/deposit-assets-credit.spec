

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

abstract contracts[] cs;

contract BankTest is Test {       
    address immutable bank_deployer;      
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_deposit_assets_credit_violation() public {

        abstract transaction[] txs;


        abstract uint256 msg_value;
        abstract address sender;
        uint256 credits_slot = uint256(0);
        bytes32 sender_credits_slot = keccak256(abi.encode(sender, credits_slot));
        uint256 sender_creditsBefore = uint256(vm.load(address(bank), sender_credits_slot));

        vm.prank(sender);
        bank.deposit{value: msg_value}(); // should not revert 
	
        uint256 sender_creditsAfter = uint256(vm.load(address(bank), sender_credits_slot));

        assertNotEq(sender_creditsAfter, sender_creditsBefore + msg_value, "sender credits did increase by msg.value");
    }
}
