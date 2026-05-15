
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

//        "withdraw-not-revert": "a `withdraw(amount)` call does not revert if `amount` is bigger than zero and less or equal to the credit of `msg.sender`.", 

abstract contracts[] cs;


contract BankTest is Test {     
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank(abstract constructor_params);
    }

    function test_not_withdraw_revert_violation() public {
        abstract transaction[] txs;

        abstract address user;
        
        abstract uint256 amount;
        assert(amount > 0 && amount <= bank.credits(user));

        vm.prank(user);
        vm.expectRevert();
        bank.withdraw(amount);
    }
}

