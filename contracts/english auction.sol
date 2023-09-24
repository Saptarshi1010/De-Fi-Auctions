// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address, address, uint) external;
}

contract EnglishAuction {
    IERC721 public immutable nft;

    uint public nftId;
    uint public endat;
    bool public started;
    bool public ended;
    address payable public immutable seller;
    address public highestbidder;
    uint public highestbid;

    // to store the total amounts of bids by each acc that is not the highestbid
    mapping(address => uint) public bids;

    event start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address highestbidder, uint highestbid);

    constructor(address _nft, uint _nftId, uint _startingbid) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestbid = _startingbid;
    }

    function startBid() external {
        require(msg.sender == seller, "not seller");
        require(!started, "started");
        started = true;
        endat = uint32(block.timestamp + 60);
        nft.transferFrom(msg.sender, address(this), nftId);
        emit start();
    }

    function bid() external payable {
        require(started, "bid started");
        require(block.timestamp > endat, "auction still going");
        require(msg.value > highestbid, "not enough bid");

        if (highestbidder != address(0)) {
            //highestbidder cannot be address 0
            bids[highestbidder] += highestbid; //keeps track of all the bids that were outbid so that they can withdraw it later
        }

        msg.value == highestbid;
        msg.sender == highestbidder;
        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external payable {
        uint bal = bids[msg.sender]; // total bids which are not highest bids are stored in bal
        bids[msg.sender] = 0; // to protect from being interupted
        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    function end() external {
        require(block.timestamp >= endat, "ended");
        ended = true;

        //if someone  bid on the nft
        if (highestbidder != address(0)) {
            nft.transferFrom(address(this), highestbidder, nftId);
            seller.transfer(highestbid);
            // if someone doesnt bid on the nft we will transfer the ownership back to the seller
        } else {
            nft.transferFrom(address(this), seller, nftId);
        }
        emit End(highestbidder, highestbid);
    }
}
