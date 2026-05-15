pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract BankTest is Test {
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    function test_withdraw_revert_violation() public {
        // Fund this test contract and deposit so credits[tx.origin] (set to this later) is non-zero
        vm.deal(address(this), 2 ether);
        bank.deposit{value: 2 ether}();

        address user = address(0xA11CE);
        uint256 amount = 1 ether;

        uint256 user_creditsBefore = bank.credits(user);

        // Ensure the assertion holds: user has no credits, so amount > user_creditsBefore
        assert(amount == 0 || amount > user_creditsBefore);
                
        // Set msg.sender=user, tx.origin=this contract (which has credits from the deposit)
        vm.prank(user, address(this));
        bank.withdraw(amount); 
    }
}