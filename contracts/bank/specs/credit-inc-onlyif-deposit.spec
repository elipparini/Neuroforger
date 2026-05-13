

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

abstract contracts[] cs;

contract BankTest is Test {       
    address immutable bank_deployer;      
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        abstract address bank_deployer;
        vm.prank(bank_deployer);
        bank = new Bank();
    }
    
    function test_credits_inc_onlyif_deposit_violation() public {

        abstract transaction[] txs;

        abstract address user;
        assertNotEq(user, address(bank), "user address equal to bank address");

        uint256 user_credits_before = bank.credits(user);

        abstract address sender;
        vm.prank(sender);

        abstract bytes4 function_selector;
        abstract uint256 msg_value;
        abstract bytes memory params;

        // Dynamically call the function with function_selector selector and passed parameters
        address(bank).call{value: msg_value}(abi.encodeWithSelector(function_selector, params));        
	
        assert(function_selector != bank.deposit.selector || sender != user);

        uint256 user_credits_after = bank.credits(user);
        assertGt(user_credits_after, user_credits_before, "user credits did not increase");
    }
}

