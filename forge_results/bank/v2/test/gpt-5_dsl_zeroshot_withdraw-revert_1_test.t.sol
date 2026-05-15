pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Dummy {}

contract BankTest is Test {
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xDEAD);
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    function test_withdraw_revert_violation() public {
        // Fund the bank with 1 wei from a different user
        vm.deal(address(0xABCD), 1);
        vm.prank(address(0xABCD));
        bank.deposit{value: 1}();

        address user = address(0xBEEF);
        
        uint256 amount = 1;

        uint256 user_creditsBefore = bank.credits(user);

        assert(amount == 0 || amount > user_creditsBefore);
                
        vm.prank(user);
        bank.withdraw(amount); 
    }
}