
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

    function test_withdraw_revert_violation() public {
        abstract transaction[] txs;

        abstract address user;
        
        abstract uint256 amount;

        uint256 user_creditsBefore = bank.credits(user);

        assert(amount == 0 || amount > user_creditsBefore);
                
        vm.prank(user);
        bank.withdraw(amount); 
    }
}

