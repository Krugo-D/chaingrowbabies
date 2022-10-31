// SPDX-License-Identifier: MIT
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


pragma solidity 0.8.9;

contract ChainGrowBabiesNFT is ChainlinkClient, ERC721URIStorage, Ownable {
    using Chainlink for Chainlink.Request;
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    IERC20 private token;

    struct City {
        string name;
        uint24 precipitationPastHour;
        int16 temperature;
        uint16 windSpeed;
        uint256 lastUpdated;
    }

    struct Baby {
        uint256 growth; // how close to harvest is your baby
        uint256 locationKey; // where is your baby
        uint256 stamina; // how often can your baby move
        uint256 agility; // how quick can your baby move
        uint256 energy; // how often can your baby move
        uint256 lastMoved; // timestamp of last move
        uint256 lastClaimed; // timestamp of last growth claim
        bool harvested; // turns true when player harvests baby
    }

    // Game parameters
    bool public gameStarted = false;
    uint256 public mintCost = 100_000_000_000_000_000;
    uint256 public moveCost;
    uint256 private seed;

    mapping(uint256 => City) public cities; // maps locationKey to matching CityData
    mapping(uint256 => Baby) public babies; // keeps track of which tokenId is located in which city
    

    /* ========== CONSTRUCTOR ========== */
    /**
     * @param _link the LINK token address.
     * @param _oracle the Operator.sol contract address.
     */
    constructor(address _link, address _oracle, IERC20 _token) ERC721("ChainGrowBabies", "CGB") {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        token = _token;
    }


    /* ========== NFT FUNCTIONS ========== */

    function mint() public payable {
        require(msg.sender == tx.origin, "Reverting, Method can only be called directly by user");
        //require(msg.value >= mintCost, "Not enough ETH sent; check mint price!");
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        babies[newItemId].locationKey = random(7);
        babies[newItemId].growth = 0;
        babies[newItemId].stamina = random(10);
        babies[newItemId].agility = random(10);
        babies[newItemId].energy = random(10);
        babies[newItemId].lastMoved = block.timestamp;
        babies[newItemId].lastClaimed = block.timestamp;     
        _setTokenURI(newItemId, tokenURI(newItemId));
    }

    function random(uint256 _modulus) private returns (uint) {
        seed ++;
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender, seed))) % _modulus;
    }

    function move(uint256 tokenId, uint256 locationKey) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to move it");
        require(canMove(tokenId));
        babies[tokenId].locationKey == locationKey;
        babies[tokenId].lastMoved = block.timestamp;
        //Change locationKey of users NFT[tokenId]
    }

    function canMove(uint256 tokenId) public returns(bool) {
        
    }

    function setMintCost(uint256 newMintCost) public onlyOwner {
        mintCost = newMintCost;
    }

    function setMoveCost(uint256 newMoveCost) public onlyOwner {
        moveCost = newMoveCost;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[17] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = (babies[tokenId].growth).toString();

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = (babies[tokenId].locationKey).toString();

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = (babies[tokenId].stamina).toString();

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = (babies[tokenId].agility).toString();

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = (babies[tokenId].energy).toString();

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = (babies[tokenId].lastMoved).toString();

        parts[12] = '</text><text x="10" y="140" class="base">';

        parts[13] = (babies[tokenId].lastClaimed).toString();

        parts[14] = '</text><text x="10" y="160" class="base">';

        parts[15] = babies[tokenId].harvested == true ? 'true' : 'false';

        parts[16] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15], parts[16]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Baby #', (tokenId).toString(), '", "description": "ChainGrowBabies are a collection of ...", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    /* ========== ORACLE REQUEST & FULFILL FUNCTIONS ========== */

    // Temporary function to set mock weather data per city. This should eventually be handled by Chainlink oracle and keeper
    function updateCityWeatherData(uint256 locationKey, uint24 _precipitationPastHour, int16 _temperature, uint16 _windSpeed) public onlyOwner() {
        cities[locationKey].precipitationPastHour = _precipitationPastHour;
        cities[locationKey].temperature = _temperature;
        cities[locationKey].windSpeed = _windSpeed;
        cities[locationKey].lastUpdated = block.timestamp;
    } 

    /* ========== OTHER FUNCTIONS ========== */

    function getOracleAddress() external view returns (address) {
        return chainlinkOracleAddress();
    }

    function setOracle(address _oracle) external onlyOwner {
        setChainlinkOracle(_oracle);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }
}