pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// concretization of `abstract contracts[] cs;`
contract C0 {}

contract BankTest is Test {     
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xB0B);
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    function test_not_deposit_revert_violation() public {
        // concretization of `abstract transaction[] txs;`
        vm.deal(address(0xBEEF), 0);

        // concretization of `abstract address user;`
        address user = address(0x1337);
        
        vm.prank(user);
        // concretization of `abstract uint256 msg_value;`
        uint256 msg_value = 0;

        vm.expectRevert();
        bank.deposit{value: msg_value}();
    }
}