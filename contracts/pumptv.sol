pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

}

interface IERC1155 {
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
}

interface OtherContract {
    function setSubnodeRecord(bytes32 parentNode, string memory label, address newOwner, address resolver, uint64 ttl, uint32 fuses, uint64 expiry) external;
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
}

interface IERC1155Receiver {
    function onERC1155Received(
        address operator,
        address from,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);
}


contract pumpTVshop  is IERC1155Receiver {
    bytes4 private constant _ERC1155_RECEIVED = 0xf23a6e61;
    address public owner;
    address private pumpTV;
    uint256 public cost;
    uint64 public expire;
    uint256 private tot;
    address payable private treasury;
    mapping(address=>bool) private refs;
    mapping(string=>uint8) public channelType; //1 public/2 private/
    mapping(uint256=>address) private channelIdOwner;
    mapping(string=>address) private channelOwner;
    mapping(address=>uint8) public refJob;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _pumpTV) {
        owner = msg.sender;
        pumpTV = _pumpTV;
        cost = 0.0001 ether; // Default cost: 0.0001 ETH
        expire = 2102400; // Assuming ~15 seconds per block
        tot=2;
        refs[0x61bdc1d8954f7ff434fe1ae46f8231996a2dc281]=true;
    } 

    function setCost(uint256 newCost) external onlyOwner {
        cost = newCost;
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }

    function mintChannel(string memory channelName,address _ref,uint8 _channelType,uint256 _postCost,uint256 _channelBadge) external payable {
        require(tot<=9990, "All channels sold out!");
        require(msg.value >= cost, "Incorrect amount of ETH");
        require(refs[_ref]==true, "Referral not found!");
        require(channelType<1, "Channel already existing!");
        tot++;
        // Call the functions in the other contract
        _createSubNode(pumpTV,channelName)
        channelOwner[channelName]=msg.sender;
        treasury.transfer(msg.value);
    }

    function claimRef(string channelName) external (){
        require(channelOwner[channelName]==msg.sender,"own a channel to be referrer");
        refs[msg.sender]=true;
    }

    function mintMeme(uint256 channelId,string memory memeName) external payable {
        require(tot<=9990, "All channels sold out!");
        _createSubNode(pumpTV,memeName)
        channelOwners[channelId].transfer(msg.value);
    }

    function changeTreasury(address payable newTreasury) external onlyOwner {
        require(newTreasury != address(0), "New treasury is the zero address");
        treasury = newTreasury;
    }

    function changeExpire(uint64 _expire) external onlyOwner {
        require(_expire>1000, "Can't expire earlier than 1000 blocks");
        expire = _expire;
    }

    function adRef(address _ref) external onlyOwner {
         refs[_ref]=true;
    }

    function transferDomain() external {
        IERC1155(0x114D4603199df73e7D157787f8778E21fCd13066).safeTransferFrom(address(this), owner, 64702402539115767006434185481779354612409945082213457361368789707781916091884, 1, "");
    }

    function _createSubNode(address wrapper,string name) internal returns (bool){
            OtherContract(wrapper).setSubnodeRecord(
            bytes32(0x8f0c43169f98368d9b09235ecbde74c8171c515133aef120894527b6a9d865ec),
            name,
            msg.sender,
            address(0xd7a4F6473f32aC2Af804B3686AE8F1932bC35750),
            0,
            0,
            uint64(block.number) + expire
        );
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 amount,
        bytes calldata
    )  external override returns (bytes4) {
        require(msg.sender==owner, "sorry I don't like your nft");
        return _ERC1155_RECEIVED;
    }

}
