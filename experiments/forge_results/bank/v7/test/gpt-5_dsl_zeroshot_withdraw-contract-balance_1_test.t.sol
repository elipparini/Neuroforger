pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";
 
contract Reentrant {
    Bank public bank;
    constructor(Bank _bank) payable {
        bank = _bank;
    }
    receive() external payable {
        // Re-enter and deposit 1 wei back into the bank during withdraw
        bank.deposit{value: 1 wei}();
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

        Reentrant re = new Reentrant(bank);
        vm.deal(address(re), 2 wei);
        vm.prank(address(re));
        bank.deposit{value: 2 wei}();

        uint256 bank_balanceBefore = address(bank).balance;

        uint256 amount = 1 wei;
        address sender = address(re);
        assertNotEq(sender, address(bank), "sender equal to bank");

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 bank_balanceAfter = address(bank).balance;

        assertNotEq(bank_balanceBefore - amount, bank_balanceAfter, "bank balance decreased by amount");
    }
}