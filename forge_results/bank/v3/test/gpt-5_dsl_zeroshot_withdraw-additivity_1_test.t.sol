pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract DummyC {}

contract BankTest is Test {
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank(5 ether);
    }

    function test_withdraw_additivity_violation() public {
        vm.deal(address(0x1111), 100 ether);
        vm.prank(address(0x1111));
        bank.deposit{value: 3 ether}();
        vm.prank(address(0x1111));
        bank.deposit{value: 3 ether}();

        address sender = address(0x1111);
        uint256 snapshot = vm.snapshotState();

        address user = address(0x1111);
        
        uint256 n1 = 3 ether;
        uint256 n2 = 3 ether;
        bool revert_pathA1;
        bool revert_pathA2;
        bool revert_pathB;

        vm.prank(sender);
        (bool successA1, ) = address(bank).call(abi.encodeWithSignature("withdraw(uint256)", n1));
        revert_pathA1 = !successA1;

        vm.prank(sender);
        (bool successA2, ) = address(bank).call(abi.encodeWithSignature("withdraw(uint256)", n2));
        revert_pathA2 = !successA2;


        uint256 user_credits_pathA = bank.credits(user);
        uint256 user_balance_pathA = user.balance;

        vm.revertToState(snapshot);

        vm.prank(sender);
        (bool successB, ) = address(bank).call(abi.encodeWithSignature("withdraw(uint256)", n1 + n2));
        revert_pathB = !successB;

        uint256 user_credits_pathB = bank.credits(user);
        uint256 user_balance_pathB = user.balance;

        assertNotEq(user_credits_pathB, user_credits_pathA, "Credits are equal");
        assertNotEq(user_balance_pathB, user_balance_pathA, "Balances are equal");
    }
}