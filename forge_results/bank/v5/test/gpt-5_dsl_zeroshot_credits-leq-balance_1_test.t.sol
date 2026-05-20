pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Concretization of abstract contracts[]
contract Dummy {}

contract BankTest is Test {
    Bank immutable bank;

    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    // Helper: Dynamically locate the base storage slot of the credits mapping via vm.store/vm.load.
    // Writes a sentinel value into credits[probe] via vm.store, then scans candidate slots
    // with vm.load to find which one holds it, recovering the mapping's base slot.
    function findCreditsBaseSlot() internal returns (uint256) {
        address probe = address(uint160(1)); // arbitrary non-zero address
        uint256 sentinel = 0xaeaeaeae;
        // Try each candidate base slot, write sentinel there, check if credits(probe) reflects it
        for (uint256 k = 0; k < 32; k++) {
            bytes32 slot = keccak256(abi.encode(probe, k));
            vm.store(address(bank), slot, bytes32(sentinel));
            if (bank.credits(probe) == sentinel) {
                // Restore the slot to 0 before returning
                vm.store(address(bank), slot, bytes32(0));
                return k;
            }
            vm.store(address(bank), slot, bytes32(0)); // clean up failed candidate
        }
        revert("Could not find credits base slot");
    }

    // Helper: Accumulate credit deltas by iterating over all storage writes.
    // For each non-reverted write whose slot matches credits[accessor],
    // add (newValue - previousValue) to the running sum.
    function accumulateCredits(Vm.AccountAccess[] memory accesses, uint256 creditsBaseSlot)
        internal
        view
        returns (int256)
    {
        int256 totalCredits = 0;
        for (uint256 i = 0; i < accesses.length; i++) {
            bytes32 expectedSlot = keccak256(abi.encode(accesses[i].accessor, creditsBaseSlot));
            Vm.StorageAccess[] memory storageAccesses = accesses[i].storageAccesses;
            for (uint256 j = 0; j < storageAccesses.length; j++) {
                Vm.StorageAccess memory sa = storageAccesses[j];
                if (
                    sa.account == address(bank) &&
                    sa.isWrite &&
                    !sa.reverted &&
                    sa.slot == expectedSlot
                ) {
                    totalCredits += int256(uint256(sa.newValue)) - int256(uint256(sa.previousValue));
                }
            }
        }
        return totalCredits;
    }

    function test_credits_leq_balance_violation() public {
        // Open the EVM storage-write recording window.
        // Analogous to CVL initialising the ghost variable to 0 at deployment.
        vm.startStateDiffRecording();

        // Concretization of abstract transaction[] txs;
        bank.deposit{value: 0}();

        // Retrieve every SSTORE that occurred during txs.
        Vm.AccountAccess[] memory accesses = vm.stopAndReturnStateDiff();

        // Compute the base slot of the credits mapping and accumulate deltas.
        uint256 creditsBaseSlot = findCreditsBaseSlot();
        int256 totalCredits = accumulateCredits(accesses, creditsBaseSlot);

        // Violation: sum of all users' credits exceeds the Bank's ETH balance
        assert(totalCredits > int256(address(bank).balance));
    }
}