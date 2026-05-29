pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";
 
contract Reverter {
    receive() external payable {
        revert("nope");
    }
}

contract BankTest is Test {          
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    
    function test_withdraw_contract_balance() public {

        Reverter attacker = new Reverter();
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker));
        bank.deposit{value: 1 ether}();

        uint256 bank_balanceBefore = address(bank).balance;

        uint256 amount = 1 ether;
        address sender = address(attacker);
        assertNotEq(sender, address(bank), "sender equal to bank");

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 bank_balanceAfter = address(bank).balance;

        assertNotEq(bank_balanceBefore - amount, bank_balanceAfter, "bank balance decreased by amount");
    }
}