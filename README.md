# Auction Smart Contract

Built as a project whilst working through this course: https://www.udemy.com/course/master-ethereum-and-solidity-programming-with-real-world-apps/

A decentralised auction application.

- smart contract ebay alternative
- auction has an owner, a start date and an end date
- owner can cancel the auction at any time, or finalise it after the end date.
- bidders send eth by calling function 'placeBid()', sender and amount sent are stored in a mapping variable called bids.
- bidders can bid the maximum they are willing to pay, but only pay the amount of the second highest bid + 0.01 eth, the contract will autmotically id up to the given max bid amount.
- the highestBindingBid s the selling price and the highestBidder is the person who won the auction.
- After the auction ends, the owner gets the highestBindingBid and everybody else gets thier bid amount returned.



