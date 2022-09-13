//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract Auction{
    address payable public owner;

    // used to calculate start and end times
    uint public startBlock;
    uint public endBlock;

    // using IPFS so we don't have to store averything on bloackchain
    string public ipfhHash;

    // allowable auction states
    enum State {Started, Running, Ended, Cancelled}
    State public auctionState;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping(address=>uint) public bids;

    uint bidIncrement;

    constructor(address _eoa){
        owner = payable(_eoa);
        //owner = payable(msg.sender);
        auctionState = State.Running;
        startBlock = block.number;
        // 1 week is approximately 40320 blocks at 15 seconds per block
        endBlock = startBlock + 40320;
        ipfhHash = "";
        bidIncrement = 0.01 ether;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }

    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }

    function min(uint a, uint b) internal pure returns(uint){
        if (a<= b){
            return a;
        }
        else{
            return b;
        }
    }

    function placeBid() public payable notOwner afterStart beforeEnd {
        // make sure auction is running
        require(auctionState == State.Running);
        // make sure bid is greater than the minimum increment
        require(msg.value >= bidIncrement);

        // caclulate the bidder new total bid amount
        uint currentBid = bids[payable(msg.sender)] + msg.value;

        // make sure the bid will make a difference to the auction
        require(currentBid > highestBindingBid);

        // set the bidders new taotal bid amount
        bids[payable(msg.sender)] = currentBid;

        // if the new bid still doesn't beat the previous highest bidder
        // either increment the highestBindingBid or set it to the max bid
        if (currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        }else{
            // either increment the highestBindingBid or set it to the max bid
            highestBindingBid = min(bids[highestBidder] + bidIncrement, currentBid);
            // change the highestBidder to new bidder
            highestBidder = payable(msg.sender);
        }
    }

    function cancelAuction() public onlyOwner{
        auctionState = State.Cancelled;
    }

    function finaliseAuction() public {
        require (auctionState == State.Cancelled || auctionState == State.Ended);
        require (msg.sender == owner && highestBindingBid > 0 || bids[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint value;

        // if auction was cancelled the owner gets nothing, all bidders get thier ETH back
        if (auctionState == State.Cancelled){
            value = bids[msg.sender]; // this will default to 0 for the owner who has no bid;
        } else { // auction ended (not cancelled)
            // owner gets the winning bid
            if (msg.sender == owner){
                value = highestBindingBid;

                // adjust highest binding bid so owner can't withdrawl more than once.
                // before doing this adjust the highestbidders balance so their withdrawl
                // logic isn't broken
                uint newValue = bids[highestBidder] - highestBindingBid;
                bids[highestBidder] = newValue;
                highestBindingBid = 0;
            } else if (msg.sender == highestBidder){ // i
                // winner can withdrawl the excess ( bids[msg.sender] - highestBindingBid )
                // if the owner has already been paid thier bid will be reduced accordingly
                // and the highestBindingBid will be 0
                value = bids[msg.sender] - highestBindingBid;
            }
            // all other bidders get thier money back
            else{ // not the owner or auction winner
                value = bids[msg.sender];
            }
        }
        // send the eth
        recipient.transfer(value);
        //update the recipients balance so they can't withdrawl again
        bids[msg.sender] = 0;
    }
}