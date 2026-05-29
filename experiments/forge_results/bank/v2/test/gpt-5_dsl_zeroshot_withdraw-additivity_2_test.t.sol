pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Replacement for `abstract contracts[] cs;`
contract Dummy {}

contract BankTest is Test {
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        // Replacement for `abstract address bank_deployer;`
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    function test_withdraw_additivity_violation() public {
        // Replacement for `abstract transaction[] txs;`
        // Fund the bank with sufficient ETH from a donor
        vm.deal(address(0xD00D), 1 ether);
        vm.prank(address(0xD00D));
        bank.deposit{value: 1 ether}();

        // Give the sender minimal credits: 1 wei
        vm.deal(address(0xA11CE), 1 wei);
        vm.prank(address(0xA11CE));
        bank.deposit{value: 1 wei}();

        // Replacement for `abstract address sender;`
        address sender = address(0xA11CE);
        uint256 snapshot = vm.snapshotState();

        // Replacement for `abstract address user;`
        address user = sender;
        
        // Replacement for `abstract uint256 n1;`
        uint256 n1 = 2;
        // Replacement for `abstract uint256 n2;`
        uint256 n2 = 2;
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

        // Path A: first call succeeds (credits: 1 -> 0, +2 wei), second reverts.
        // Path B: single call reverts (credits remain 1, balance unchanged).
        assertNotEq(user_credits_pathB, user_credits_pathA, "Credits are equal");
        assertNotEq(user_balance_pathB, user_balance_pathA, "Balances are equal");
    }
}