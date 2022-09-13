//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

import './Auction.sol';

contract AuctionCreator{

    address public ownerCreator;
    Auction[] public auctions;

    constructor(){
        ownerCreator = msg.sender;
    }

    function createAuction() public{
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}