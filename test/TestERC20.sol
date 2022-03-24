// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.5.16;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/ERC20Mintable.sol";

contract EOTCERC20 is ERC20Detailed, ERC20Mintable {
    constructor(uint amount) ERC20Detailed('EOTC Token', 'EOTC', 18) public {
        mint(msg.sender, amount);
    }
}
