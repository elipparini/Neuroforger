pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";
 
// Define a malicious recipient that force-sends ETH back to the Bank during withdraw
contract Malicious {
    Bank public bank;
    constructor(Bank _bank) {
        bank = _bank;
    }
    receive() external payable {
        selfdestruct(payable(address(bank)));
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

        // Setup: deploy malicious recipient, fund it, and deposit into bank under its address
        Malicious mal = new Malicious(bank);
        vm.deal(address(mal), 1 ether);
        vm.prank(address(mal));
        bank.deposit{value: 1 ether}();

        uint256 bank_balanceBefore = address(bank).balance;

        uint256 amount = 1 ether;
        address sender = address(mal);
        assertNotEq(sender, address(bank), "sender equal to bank");

        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 bank_balanceAfter = address(bank).balance;

        // After withdraw: bank sent out 'amount' but received it back via selfdestruct
        // Hence bank_balanceAfter == bank_balanceBefore, which is != bank_balanceBefore - amount
        assertNotEq(bank_balanceBefore - amount, bank_balanceAfter, "bank balance decreased by amount");
    }
}