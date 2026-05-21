pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// "deposit-not-revert-int-or-ext": "a `deposit` transaction never reverts"
// Covers both external calls (originating from an EOA or the test) and internal calls
// (deposit invoked as a nested call, e.g. from a reentrancy scenario).
//
// deposit-not-revert.spec handles only direct external calls via vm.expectRevert().
// That idiom cannot detect a revert inside a nested call that is itself caught by the
// outer frame.  Instead, we use EVM state-diff recording to obtain every AccountAccess
// produced during the transaction sequence, then search for any CALL to bank.deposit()
// whose reverted flag is true — regardless of call depth.

abstract contracts[] cs;

contract BankTest is Test {
    Bank immutable bank;

    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank(abstract constructor_params);
    }

    // Helper: extract the 4-byte function selector from the front of a calldata blob.
    function extractSelector(bytes memory data) internal pure returns (bytes4 sel) {
        assembly { sel := mload(add(data, 0x20)) }
    }

    // Helper: check if any CALL to bank.deposit() reverted in the given account accesses.
    // Scans all call frames (at any depth) to find a reverted deposit call.
    function hasDepositReverted(Vm.AccountAccess[] memory accesses) internal view returns (bool) {
        for (uint256 i = 0; i < accesses.length; i++) {
            Vm.AccountAccess memory acc = accesses[i];
            if (
                acc.account == address(bank) &&
                uint8(acc.kind) == 0 && // 0 = AccountAccessKind.Call
                acc.data.length >= 4 &&
                extractSelector(acc.data) == bank.deposit.selector &&
                acc.reverted
            ) {
                return true;
            }
        }
        return false;
    }

    function test_deposit_not_revert_int_or_ext_violation() public {
        // Open the EVM call-trace recording window before any transactions.
        vm.startStateDiffRecording();

        abstract transaction[] txs;

        // Retrieve every account access (call frame) that occurred during txs.
        Vm.AccountAccess[] memory accesses = vm.stopAndReturnStateDiff();

        // Violation: at least one deposit call (internal or external) reverted
        assert(hasDepositReverted(accesses));
    }
}
