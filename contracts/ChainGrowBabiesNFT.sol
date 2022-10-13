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
    IERC20 private _token;

    struct City {
        uint24 precipitationPastHour;
        int16 temperature;
        uint16 windSpeed;
        uint256 lastUpdated;
    }

    struct Baby {
        uint256 locationKey; // where is your baby
        uint256 growth; // how close to harvest is your baby
        uint256 stamina; // how often can your baby move
        uint256 agility; // how quick can your baby move
        uint256 energy; // how often can your baby move
        uint256 lastMoved; // timestamp of last move
        uint256 lastClaimed; // timestamp of last growth claim
    }

    // Game parameters
    bool public gameStarted = false;
    uint256 public mintCost;
    uint256 public moveCost;

    mapping(uint256 => City) public cities; // maps locationKey to matching CityData
    mapping(uint256 => Baby) public babies; // keeps track of which tokenId is located in which city
    

    /* ========== CONSTRUCTOR ========== */
    /**
     * @param _link the LINK token address.
     * @param _oracle the Operator.sol contract address.
     */
    constructor(address _link, address _oracle, IERC20 token) ERC721("ChainGrowBabies", "CGB") {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        _token = token;
    }


    /* ========== NFT FUNCTIONS ========== */

    //hardcoded now but will use Chainlink VRF for random characteristics (1-10)
    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        //call VRF oracle here and feed return data in to the struct
        babies[newItemId].locationKey = 0;
        babies[newItemId].growth = 0;
        babies[newItemId].stamina = 6;
        babies[newItemId].agility = 2;
        babies[newItemId].energy = 9;
        babies[newItemId].lastMoved = 0;
        babies[newItemId].lastClaimed = 0;     
        _setTokenURI(newItemId, getTokenURI(newItemId));
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

    //possibly remove getter functions and access cities mapping directly?
    function generateCharacter(uint256 tokenId) public view returns(string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">',"ChainGrowBaby",'</text>',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">', "Location: ",(babies[tokenId].locationKey).toString(),'</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Growth: ",(babies[tokenId].growth).toString(),'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Stamina: ",(babies[tokenId].stamina).toString(),'</text>',            
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Agility: ",(babies[tokenId].agility).toString(),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Energy: ",(babies[tokenId].energy).toString(),'</text>',            
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "LastMoved: ",(babies[tokenId].lastMoved).toString(),'</text>',            
            '<text x="50%" y="90%" class="base" dominant-baseline="middle" text-anchor="middle">', "LastClaimed: ",(babies[tokenId].lastClaimed).toString(),'</text>',            
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "ChainGrowBaby #', tokenId.toString(), '",',
                '"description": "Grows on-chain!",',
                '"":image "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
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