// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Whitelist } from "./Whitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
  uint256 constant public _PRICE = 0.01 ether;

  uint256 constant public MAX_TOKEN_IDS = 20;

  Whitelist whitelist;

  uint256 public reservedTokens;
  uint256 public reservedTokensClaimed = 0;


  constructor(address whitelistContract) ERC721("CryptoDev", "CD") Ownable(msg.sender) {
    whitelist = Whitelist(whitelistContract);
    reservedTokens = whitelist.maxWhitelistedAddresses();
  }

  function mint() public payable {
    require(totalSupply() + reservedTokens - reservedTokensClaimed < MAX_TOKEN_IDS, "EXCEEDED_MAX_SUPPLY");

    if (whitelist.whitelistedAddresses(msg.sender) && msg.value < _PRICE) {
      require(balanceOf(msg.sender) == 0, "ALREADY_OWNED");
      reservedTokensClaimed += 1;
    } else {
      require(msg.value >= _PRICE, "NOT_ENOUGH_ETHER");
    }

    uint256 tokenId = totalSupply();
    _safeMint(msg.sender, tokenId);
  }

  function withdraw() public onlyOwner {
    address _owner = owner();
    uint256 amount = address(this).balance;
    (bool sent, ) = _owner.call{value: amount}("");
    require(sent, "Failed to send Ether");
  }
}
