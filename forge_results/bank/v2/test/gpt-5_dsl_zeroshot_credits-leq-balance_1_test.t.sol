pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Dummy {}

contract BankTest is Test {
    Bank immutable bank;

    constructor() {
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    function findCreditsBaseSlot() internal returns (uint256) {
        address probe = address(uint160(1)); // arbitrary non-zero address
        uint256 sentinel = 0xaeaeaeae;
        for (uint256 k = 0; k < 32; k++) {
            bytes32 slot = keccak256(abi.encode(probe, k));
            vm.store(address(bank), slot, bytes32(uint256(sentinel)));
            if (bank.credits(probe) == sentinel) {
                vm.store(address(bank), slot, bytes32(0));
                return k;
            }
            vm.store(address(bank), slot, bytes32(0));
        }
        revert("Could not find credits base slot");
    }

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
        vm.startStateDiffRecording();

        vm.deal(address(0xA11CE), 1);
        vm.prank(address(0xA11CE));
        bank.deposit{value: 1}();
        vm.prank(address(0xA11CE));
        bank.withdraw(1);

        Vm.AccountAccess[] memory accesses = vm.stopAndReturnStateDiff();

        uint256 creditsBaseSlot = findCreditsBaseSlot();
        int256 totalCredits = accumulateCredits(accesses, creditsBaseSlot);

        assert(totalCredits > int256(address(bank).balance));
    }
}