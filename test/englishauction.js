const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("English Auction", function () {
  let auction, seller, bidder1, bidder2, nftid;
  beforeEach(async function () {
    [seller, bidder1, bidder2] = await ethers.getSigner();
    auction = await ethers.getContractFactory();
    await auction.deploy();
  })
  describe("Deployment", function () {
    it("set the nftid ,seller & highestbid", async function () {
      expect(await auction.nftid()).to.equal(1);
      expect(await auction.seller()).to.equal(seller.address);
      expect(await auction.highestbid()).to.equal(0);
    })
  });

  describe("Start bid", function () {
    it("revert for owner error", async function () {
      expect(await auction.seller()).to.be.revertedWith("not seller");
    })
    it("bid started", async function () {
      expect(await auction.started()).to.equal(true);
    })
    //from here
    it("transfer", async function () {
      await expect(auction.transfer(bidder1.address, 50)).to.changeTokenBalances(auction, [owner, bidder1], [-50, 50]);
    })
    it("should emit start", async function () {
      await expect(auction.transfer(addr1.address, 50)).to.emit(auction, "Transfer").withArgs(owner.address, addr1.address, 50);

    })
  });

  describe("the biddings", function () {
    it("revert for if bid started error ", async function () {
      expect(await auction.started()).to.be.revertedWith("bid started");
    })
    it("bidding value and address", async function () {
      await auction.connect(bidder1).bid({ value: ethers.utils.parseEther("1") })
      expect(await auction.highestBidder()).to.equal(bidder1.address);
      expect(await auction.highestBid()).to.equal(ethers.utils.parseEther("1"))

      await auction.connect(bidder1).bid({ value: ethers.utils.parseEther("2") })
      expect(await auction.highestBidder()).to.equal(bidder1.address);
      expect(await auction.highestBid()).to.equal(ethers.utils.parseEther("2"))
    })
    it("should emit bidding events", async function () {
      await expect(auction.transfer(bidder11.address, 50)).to.emit(auction, "Transfer")
        .withArgs(seller.address, bidder1.address, 50);
    })
  });

  describe("Withdraw", function () {
    it("withdraw the bids which are not the highest bids", async function () {
      const bal = await auction.bids().to.equal(bidder2.address);
      expect(await auction.bal()).to.equal(0);
      await expect(auction.transfer(bal))
    })
    it("emit the withdrawing event", async function () {
      await expect(auction.transfer(bidder2.address, 5)).to.emit(auction, "Withdraw")
        .withArgs(bidder2ddr2.address, bal);
    })
  });

  describe("Auction ended", function () {
    it("auction ended", async function () {
      expect(await auction.ended()).to.equal(true);
    });
    it("emit the auction end", async function () {
      await expect(auction.transfer(seller.address, 50)).to.emit(auction, "End")
        .withArgs(highestBidder, highestBid);
    })
  })
})