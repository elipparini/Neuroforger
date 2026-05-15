pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

contract Attacker {
    Bank public immutable bank;
    uint256 public depositOnFallback;

    constructor(Bank _bank) payable {
        bank = _bank;
    }

    // Seed initial credits using the contract's own balance
    function depositFromBalance(uint256 amt) external {
        bank.deposit{value: amt}();
    }

    function setDepositOnFallback(uint256 amt) external {
        depositOnFallback = amt;
    }

    receive() external payable {
        if (depositOnFallback > 0) {
            uint256 amt = depositOnFallback;
            // One-shot to avoid unintended repeats
            depositOnFallback = 0;
            bank.deposit{value: amt}();
        }
    }
}

contract BankTest is Test {       
    Bank immutable bank;
    
    constructor() {
        // deploying a Bank contract
        address bank_deployer = address(0xBEEF);
        vm.prank(bank_deployer);
        bank = new Bank(/* no params */);
    }
    
    function test_credits_inc_onlyif_deposit_violation() public {

        // Setup attacker and seed state
        Attacker attacker = new Attacker(bank);
        vm.deal(address(attacker), 10 ether);
        attacker.depositFromBalance(1 ether);       // credit[user] = 1 ether
        attacker.setDepositOnFallback(2 ether);     // will deposit 2 ether upon receiving ETH from withdraw

        address user = address(attacker);
        assertNotEq(user, address(bank), "user address equal to bank address");

        uint256 user_credits_before = bank.credits(user);

        address sender = address(attacker);
        vm.prank(sender);

        // Use withdraw; with params as bytes, the first word (0x20) is read as amount = 32 wei
        bytes4 function_selector = bank.withdraw.selector;
        uint256 msg_value = 0;
        bytes memory params = hex"";

        // Dynamically call withdraw; this triggers receive() on attacker, which deposits 2 ether back
        address(bank).call{value: msg_value}(abi.encodeWithSelector(function_selector, params));        
	
        assert(function_selector != bank.deposit.selector || sender != user);

        uint256 user_credits_after = bank.credits(user);
        assertGt(user_credits_after, user_credits_before, "user credits did not increase");
    }
}