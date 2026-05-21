pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Attacker {
    Bank public bank;

    constructor(Bank _bank) {
        bank = _bank;
    }

    function pwn() external payable {
        // Seed balance and then withdraw to trigger receive()
        bank.deposit{value: msg.value}();
        bank.withdraw(msg.value);
    }

    receive() external payable {
        // Re-enter deposit during withdraw; this must revert due to nonReentrant.
        // Swallow the revert so the outer withdraw succeeds.
        try bank.deposit{value: 0}() {
        } catch {
        }
    }
}

contract BankTest is Test {
    Bank immutable bank;

    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank();
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

        Attacker attacker = new Attacker(bank);
        vm.deal(address(attacker), 1 ether);
        attacker.pwn{value: 1 ether}();

        // Retrieve every account access (call frame) that occurred during txs.
        Vm.AccountAccess[] memory accesses = vm.stopAndReturnStateDiff();

        // Violation: at least one deposit call (internal or external) reverted
        assert(hasDepositReverted(accesses));
    }
}