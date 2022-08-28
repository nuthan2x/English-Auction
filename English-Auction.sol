//SPDX-License-Identifier: MIT

pragma solidity >=0.8.16;

interface IERC721{
    function safeTransferFrom(address from,address to,uint tokenID) external;
    function transferFrom(address,address,uint) external;
}

contract English_AUCTION{

    event Start(uint timestamp);
    event Bid(address bidder,uint bid);
    event Withdraw(address bidder,uint bid);
    event End(address highestbidder,uint highestbid);

    
    IERC721 public immutable mynft;
    uint public immutable nftID;
    address payable public seller;

    address public highestbidder;
    uint public highestbid;
    uint32 public endAt;
    bool public started;
    bool public ended;

    mapping(address => uint) public bids;
    uint public totalbids;

    constructor(address _mynft,uint _nftID,uint _highestbid){
        seller = payable(msg.sender);
        mynft = IERC721(_mynft);
        nftID =_nftID;
        highestbid = _highestbid;
    }

    function start() external {
        require(!started,"already started");
        require(msg.sender == seller);
        endAt = uint32(block.timestamp + 1 days );

        mynft.safeTransferFrom(msg.sender, address(this), nftID);
        started = true;
        emit Start(block.timestamp);

    }

    function bid() external payable {
        require(started,"its ended");
        require(block.timestamp < endAt);
        require(msg.value > highestbid);

        bids[msg.sender] = msg.value;

        highestbid = msg.value;
        highestbidder = msg.sender;
        totalbids += 1;
        emit Bid(msg.sender,msg.value);

    }

    function withdraw(uint _mybid) external {
        require(msg.sender != highestbidder);
        require(_mybid == bids[msg.sender]);

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(_mybid);
        emit Withdraw(msg.sender,_mybid);
    }

    function EndAuction() external{
        require(block.timestamp > endAt);
        require(started && !ended);

        if(totalbids == 0){
            mynft.transferFrom(address(this), seller, nftID);
            emit End(seller,0);
        }else{
            seller.transfer(highestbid);
            mynft.transferFrom(address(this), highestbidder, nftID);
            emit End(highestbidder,highestbid);
        }
        ended = true;
           
    } 

}
