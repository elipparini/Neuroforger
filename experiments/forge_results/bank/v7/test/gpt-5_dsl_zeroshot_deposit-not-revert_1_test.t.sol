pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";



contract BankTest is Test {     
    Bank immutable bank;
    
    constructor() {
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    function test_not_deposit_revert_violation() public {
        // no preparatory transactions
        

        address user = address(0xCAFE);
        
        vm.prank(user);
        uint256 msg_value = 0;

        vm.expectRevert();
        bank.deposit{value: msg_value}();
    }
}