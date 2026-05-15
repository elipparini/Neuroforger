pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Replacement for: abstract contracts[] cs;
contract Attacker {
    Bank public bank;

    constructor(Bank _bank) payable {
        bank = _bank;
    }

    receive() external payable {
        // On each withdrawal receipt, deposit 2 wei back into the bank.
        bank.deposit{value: 2}();
    }
}

contract BankTest is Test {
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF); // Replacement for: abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    function test_withdraw_additivity_violation() public {
        // Replacement for: abstract transaction[] txs;
        Attacker attacker = new Attacker(bank);
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker));
        bank.deposit{value: 10}(); // fund bank and attacker credits

        address sender = address(attacker); // Replacement for: abstract address sender;
        uint256 snapshot = vm.snapshotState();

        address user = sender; // Replacement for: abstract address user;
        
        uint256 n1 = 1; // Replacement for: abstract uint256 n1;
        uint256 n2 = 1; // Replacement for: abstract uint256 n2;
        
        vm.prank(sender);
        bank.withdraw(n1);
        vm.prank(sender);
        bank.withdraw(n2);

        uint256 user_credits_pathA = bank.credits(user);
        uint256 user_balance_pathA = user.balance;

        vm.revertToState(snapshot);

        vm.prank(sender);
        bank.withdraw(n1 + n2);

        uint256 user_credits_pathB = bank.credits(user);
        uint256 user_balance_pathB = user.balance;

        // Path A: credits = 10 -1 +2 -1 +2 = 12; balance change = 0
        // Path B: credits = 10 -2 +2 = 10; balance change = +1 wei
        assertNotEq(user_credits_pathB, user_credits_pathA, "Credits are equal");
        assertNotEq(user_balance_pathB, user_balance_pathA, "Balances are equal");
    }
}