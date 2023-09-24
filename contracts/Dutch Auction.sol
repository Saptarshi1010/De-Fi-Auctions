// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address _from, address _to, uint _nftId) external;
}

contract DutchAuction{

    uint public constant duration = 7 days;

    IERC721 public immutable nft;

    uint public nftid;
    uint public startat;
    address payable  public seller;
    uint public startingprice;
    uint public expiresat;
    uint public discountrate;

    constructor(address _nft, uint _nftid,uint _startingprice,uint _discountrate) {
        nft= IERC721(_nft);
        nftid= _nftid;
        seller= payable(msg.sender); 
        startingprice=_startingprice;
        discountrate=_discountrate;
        startat=block.timestamp;
        expiresat= duration+ block.timestamp;

        require(_startingprice>=_discountrate * duration, "stratingprice< discount");
    }

    function getprice() public view returns(uint) {
        uint timeElapsed= block.timestamp-startat;
        uint discount = discountrate*timeElapsed;
        return  (startingprice-discount);
    }
    function buy() external payable {
        require(block.timestamp<expiresat, "auction has expired");
        uint price= getprice();
        require(msg.value>= price,"ETH<price");
        nft.transferFrom(seller, msg.sender, nftid);

        // if buyer sends excess ether
        uint refund= msg.value-price;
        if(refund>0){
            payable (msg.sender).transfer(refund);
        }
       // deleting the contract so that the auction finishes
        selfdestruct(seller);

    }
}