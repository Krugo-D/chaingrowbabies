// SPDX-License-Identifier: MIT
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

pragma solidity 0.8.9;

/**
 * @title A consumer contract for AccuWeather EA 'location-current-conditions' endpoint.
 * @author LinkPool.
 * @notice Request the current weather conditions for the given location coordinates (i.e. latitude and longitude).
 * @dev Uses @chainlink/contracts 0.4.0.
 */
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
        uint8 stamina; // how often can your baby move
        uint8 agility; // how quick can your baby move
        uint8 energy; // how often can your baby move
        uint256 lastMoved; // timestamp of last move
        uint256 lastClaimed; // timestamp of last growth claim
    }

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
    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();
        _safeMint(to, tokenId);
    }

    function move(uint256 tokenId, uint256 locationKey) public {
        //Change locationKey of users NFT[tokenId]
    }

    function setMintCost(uint256 newMintCost) public onlyOwner {
        mintCost = newMintCost;
    }

    function setMoveCost(uint256 newMoveCost) public onlyOwner {
        moveCost = newMoveCost;
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