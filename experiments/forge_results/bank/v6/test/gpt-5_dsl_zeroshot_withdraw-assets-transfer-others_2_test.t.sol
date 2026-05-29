pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Concretization of `abstract contracts[] cs;`
contract SelfDestructOnReceive {
    address payable public beneficiary;
    constructor(address payable _b) payable {
        beneficiary = _b;
    }
    receive() external payable {
        selfdestruct(beneficiary);
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
    
    
    function test_withdraw_assets_transfer_others_violation() public {

        // Concretization of `abstract transaction[] txs;`
        // 1) Deploy a contract that forwards any received ETH to the zero address via selfdestruct
        SelfDestructOnReceive sd = new SelfDestructOnReceive(payable(address(0)));
        // 2) Fund the malicious sender so it can deposit into the bank
        vm.deal(address(sd), 2);
        // 3) Deposit 2 wei into the bank credited to `sd`
        vm.prank(address(sd));
        bank.deposit{value: 2}();

	    address user = address(0);
        assertNotEq(user, address(bank), "user equal to bank");

        uint256 user_balanceBefore = user.balance;

        uint256 amount = 1;
        address sender = address(sd);
        vm.prank(sender);
        bank.withdraw(amount); // should not revert 
	
        uint256 user_balanceAfter = user.balance;

        assertNotEq(sender, user, "user equal to sender");

        assertNotEq(user_balanceBefore, user_balanceAfter, "user balance did not change");
    }
}