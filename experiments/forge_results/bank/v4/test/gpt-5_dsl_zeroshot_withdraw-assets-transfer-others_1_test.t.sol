pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Forwarder that deposits initial value into Bank for itself, and on receive forwards ETH to a beneficiary
contract Forwarder {
    address payable immutable target;

    constructor(Bank b, address payable _target) payable {
        target = _target;
        b.deposit{value: msg.value}(); // credit this contract in the Bank
    }

    receive() external payable {
        (bool s,) = target.call{value: msg.value}("");
        require(s);
    }
}

contract BankTest is Test {
    Bank immutable bank;

    constructor() {
        address bank_deployer = address(this);
        vm.prank(bank_deployer);
        bank = new Bank();
    }

    function test_withdraw_assets_transfer_others_violation() public {
        // Deploy Forwarder with CREATE2 and deposit 2 wei into Bank for the Forwarder (credits = 1 wei)
        new Forwarder{value: 2, salt: bytes32(uint256(0xA))}(bank, payable(address(uint160(0xBEEF))));

        address user = address(uint160(0xBEEF));
        assertNotEq(user, address(bank), "user equal to bank");

        uint256 user_balanceBefore = user.balance;

        uint256 amount = 1; // <= credits (2 - 1)

        // Compute the CREATE2 address of the Forwarder we just deployed
        address sender = address(uint160(uint(keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                bytes32(uint256(0xA)),
                keccak256(abi.encodePacked(
                    type(Forwarder).creationCode,
                    abi.encode(bank, address(uint160(0xBEEF)))
                ))
            )
        ))));

        // Withdraw as the Forwarder; Bank sends ETH to sender (Forwarder),
        // whose receive() immediately forwards it to user.
        vm.prank(sender);
        bank.withdraw(amount);

        uint256 user_balanceAfter = user.balance;

        assertNotEq(sender, user, "user equal to sender");
        assertNotEq(user_balanceBefore, user_balanceAfter, "user balance did not change");
    }
}