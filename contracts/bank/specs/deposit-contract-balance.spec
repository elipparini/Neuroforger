

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

//        "deposit-contract-balance": "after a non-reverting `deposit()`, the ETH balance of the contract is increased by `msg.value`.",
 

abstract contracts[] cs;

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank(abstract constructor_params);
    }
    
    
    function test_deposit_contract_balance() public {

        abstract transaction[] txs;

        uint256 bank_balanceBefore = address(bank).balance;

        abstract uint256 msg_value;
        abstract address sender;
        assertNotEq(sender, address(bank), "sender equal to bank");

        vm.prank(sender);
        bank.deposit{value: msg_value}(); // should not revert 
	
        uint256 bank_balanceAfter = address(bank).balance;

        assertNotEq(bank_balanceBefore + msg_value, bank_balanceAfter, "bank balance increased by msg.value");
    }
}
