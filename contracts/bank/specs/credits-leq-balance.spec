
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// "credits-leq-balance": "the wei balance stored in the contract is greater than or equal to the sum of all the users' credits"

// Mapping iteration problem: Solidity mappings are not iterable.
// Solution using EVM state-diff recording, analogous to CVL's ghost + hook Sstore:
//
//   CVL:
//     ghost mathint sum_credits { init_state axiom sum_credits==0; }
//     hook Sstore credits[KEY address a] uint new_value (uint old_value) {
//         sum_credits = sum_credits - old_value + new_value; }
//     invariant credits_leq_balance() sum_credits <= nativeBalances[currentContract];
//
//   Foundry:
//     vm.startStateDiffRecording() opens the recording window.
//     vm.stopAndReturnStateDiff() returns every SSTORE with (previousValue, newValue).
//     Summing (newValue - previousValue) for non-reverted writes to the bank's
//     credits mapping slots reproduces sum_credits without ever enumerating addresses.
//     The base storage slot of credits is discovered dynamically via stdstore so the
//     spec is not tied to any particular Bank version's storage layout.
//     Each write is verified to target credits[accessor] by recomputing the expected
//     slot as keccak256(abi.encode(accessor, creditsBaseSlot)).

abstract contracts[] cs;

contract BankTest is Test {
    Bank immutable bank;

    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank(abstract constructor_params);
    }

    // Helper: Dynamically locate the base storage slot of the credits mapping via stdstore.
    // This avoids hard-coding slot 0 and works across Bank versions where credits
    // might not be the first declared variable.
    function findCreditsBaseSlot() internal view returns (uint256) {
        address probe = address(uint160(1)); // arbitrary non-zero address
        uint256 reportedSlot = stdstore
            .target(address(bank))
            .sig("credits(address)")
            .with_key(probe)
            .find();
        // credits[probe] lives at keccak256(abi.encode(probe, baseSlot));
        // recover baseSlot by trying small indices until the hash matches.
        for (uint256 k = 0; k < 32; k++) {
            if (uint256(keccak256(abi.encode(probe, k))) == reportedSlot) {
                return k;
            }
        }
        revert("Could not find credits base slot");
    }

    // Helper: Accumulate credit deltas by iterating over all storage writes.
    // For each non-reverted write whose slot matches credits[accessor],
    // add (newValue - previousValue) to the running sum.
    function accumulateCredits(VmSafe.AccountAccess[] memory accesses, uint256 creditsBaseSlot)
        internal
        view
        returns (int256)
    {
        int256 totalCredits = 0;
        for (uint256 i = 0; i < accesses.length; i++) {
            bytes32 expectedSlot = keccak256(abi.encode(accesses[i].accessor, creditsBaseSlot));
            VmSafe.StorageAccess[] memory storageAccesses = accesses[i].storageAccesses;
            for (uint256 j = 0; j < storageAccesses.length; j++) {
                VmSafe.StorageAccess memory sa = storageAccesses[j];
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

        abstract transaction[] txs;

        // Retrieve every SSTORE that occurred during txs.
        VmSafe.AccountAccess[] memory accesses = vm.stopAndReturnStateDiff();

        // Compute the base slot of the credits mapping and accumulate deltas.
        uint256 creditsBaseSlot = findCreditsBaseSlot();
        int256 totalCredits = accumulateCredits(accesses, creditsBaseSlot);

        // Violation: sum of all users' credits exceeds the Bank's ETH balance
        assert(totalCredits > int256(address(bank).balance));
    }
}

}
