// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract TokenLending {
    // === STATE VARIABLES ===
    IERC20 public token;

    // === BALANCES ===
    mapping(address => uint256) public tokenCollateralBalances;
    mapping(address => uint256) public tokenBorrowedBalances;
    uint256 public totalTokensInContract;

    // === EVENTS ===
    event UserHasDepositedTokens();
    event UserHasWithdrawnTokens();
    event UserHasBorrowedTokens();
    event UserHasRepaidLoan();

    constructor(address _token) {
        token = IERC20(_token);
    }

    // Deposit Function: Implement a depositToken function for users to add tokens.
    function deposit(uint256 amount) public {
        // check amount is greater than zero
        require(amount > 0, "Please deposit an amount greater than zero");

        // *** EOA should have called approval on token contract to allow this TokenLending contract to transfer tokens to itself ***

        // transfer tokens from msg.sender to this contract
        token.transferFrom(msg.sender, address(this), amount);

        // update balances
        tokenCollateralBalances[msg.sender] += amount;
        totalTokensInContract += amount;

        // emit event
        emit UserHasDepositedTokens();
    }

    // Withdraw Function: Create a withdrawToken function for users to take back their tokens.
    function withdraw(uint256 amount) public {
        // check amount is greater than zero
        require(amount > 0, "Specify an amount to withdraw");

        // check that user has an existing balance
        require(
            tokenCollateralBalances[msg.sender] >= amount,
            "You do not have enough tokens deposited to withdraw the specified amount"
        );

        // update balances
        tokenCollateralBalances[msg.sender] -= amount;
        totalTokensInContract -= amount;

        // emit event
        emit UserHasWithdrawnTokens();
    }

    // Borrow Function: Develop a borrowToken function for users to borrow tokens.
    function borrow(uint256 amount) public {
        // check amount is greater than zero
        require(amount > 0, "Specify an amount to borrow");

        // user can only borrow as much as they have deposited
        require(tokenCollateralBalances[msg.sender] >= amount, "You can only borrow up to the value of your collateral");

        // update balances
        tokenBorrowedBalances[msg.sender] += amount;
        totalTokensInContract -= amount;

        // transfer tokens to user
        token.transfer(msg.sender, amount);

        // emit event
        emit UserHasBorrowedTokens();
    }

    // Repay Function: Construct a repayToken function for users to return borrowed tokens.
    function repay(uint256 amount) public {
        // check amount is greater than zero
        require(amount > 0, "Specify an amount to repay");

        // check that user has outstanding borrowings
        require(tokenBorrowedBalances[msg.sender] > 0, "You do not have an outstanding loan");

        // transfer tokens to contract
        token.transferFrom(msg.sender, address(this), amount);

        // update balances
        tokenBorrowedBalances[msg.sender] -= amount;
        totalTokensInContract += amount;

        // emit event
        emit UserHasRepaidLoan();
    }
}
