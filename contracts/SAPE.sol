// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SAPE is ERC20 {
    using SafeMath for uint256;

    uint256 public constant BUY_FEE_PERCENT = 2; // 2% buy fee
    uint256 public constant SELL_FEE_PERCENT = 5; // 5% sell fee

    constructor() ERC20("SAPE", "SAPE") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Mint initial supply
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        uint256 fee;
        if (recipient == address(0)) {
            // Burn
            fee = 0;
        } else if (sender == address(0)) {
            // Mint
            fee = 0;
        } else {
            if (recipient != address(this)) {
                // Regular transfer
                fee = amount.mul(SELL_FEE_PERCENT).div(100);
            } else {
                // Sell
                fee = amount.mul(BUY_FEE_PERCENT).div(100);
            }
        }

        uint256 netAmount = amount.sub(fee);
        super._transfer(sender, recipient, netAmount);

        if (fee > 0) {
            super._transfer(sender, address(this), fee); // Transfer fee to contract
        }
    }

    // Custom functions for buying and selling with fees
    function buy(uint256 amount) external payable {
        require(msg.value >= amount, "Insufficient BNB");
        _transfer(address(0), msg.sender, amount);
    }

    function sell(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, address(0), amount);

        payable(msg.sender).transfer(
            amount.mul(SafeMath.sub(100, SELL_FEE_PERCENT)).div(100)
        );
    }
}
