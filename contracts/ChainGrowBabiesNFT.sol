// SPDX-License-Identifier: MIT
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

pragma solidity 0.8.9;
/**
 * **** Data Conversions ****
 *
 * countryCode (bytes2)
 * --------------------
 * ISO 3166 alpha-2 codes encoded as bytes2
 * See: https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
 *
 *
 * precipitationType (uint8)
 * --------------------------
 * Value    Type
 * --------------------------
 * 0        No precipitation
 * 1        Rain
 * 2        Snow
 * 3        Ice
 * 4        Mixed
 *
 *
 * weatherIcon (uint8)
 * -------------------
 * Each icon number is related with an image and a text
 * See: https://developer.accuweather.com/weather-icons
 *
 *
 * Decimals to integers (both metric & imperial units)
 * ---------------------------------------------------
 * Condition                    Conversion
 * ---------------------------------------------------
 * precipitationPast12Hours     multiplied by 100
 * precipitationPast24Hours     multiplied by 100
 * precipitationPastHour        multiplied by 100
 * pressure                     multiplied by 100
 * temperature                  multiplied by 10
 * windSpeed                    multiplied by 10
 *
 *
 * Current weather conditions units per system
 * ---------------------------------------------------
 * Condition                    metric      imperial
 * ---------------------------------------------------
 * precipitationPast12Hours     mm          in
 * precipitationPast24Hours     mm          in
 * precipitationPastHour        mm          in
 * pressure                     mb          inHg
 * temperature                  C           F
 * windSpeed                    km/h        mi/h
 *
 *
 * Other resources
 * ---------------
 * AccuWeather API docs:
 * http://apidev.accuweather.com/developers/
 *
 * Locations API Response Parameters:
 * http://apidev.accuweather.com/developers/locationAPIparameters#responseParameters
 *
 * Current Conditions API Response Parameters:
 * http://apidev.accuweather.com/developers/currentConditionsAPIParameters#responseParameters
 */
/**
 * @title A consumer contract for AccuWeather EA 'location-current-conditions' endpoint.
 * @author LinkPool.
 * @notice Request the current weather conditions for the given location coordinates (i.e. latitude and longitude).
 * @dev Uses @chainlink/contracts 0.4.0.
 */
contract ChainGrowBabiesNFT is ChainlinkClient, ERC721, Ownable {
    using Chainlink for Chainlink.Request;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    IERC20 private _token;

    /* ========== CONSUMER STATE VARIABLES ========== */
    struct CurrentConditionsResult {
        uint256 timestamp;
        uint24 precipitationPast12Hours;
        uint24 precipitationPast24Hours;
        uint24 precipitationPastHour;
        uint24 pressure;
        int16 temperature;
        uint16 windDirectionDegrees;
        uint16 windSpeed;
        uint8 precipitationType;
        uint8 relativeHumidity;
        uint8 uvIndex;
        uint8 weatherIcon;
    }
    struct CityWeather {
        string cityName;
        uint24 precipitationPastHour;
        int16 temperature;
        uint16 windSpeed;
        uint256 lastUpdated;
    }

    // Maps
    mapping(bytes32 => CurrentConditionsResult) public requestIdCurrentConditionsResult;
    mapping(uint256 => CityWeather) cities; // maps locationKey to matching CityData
    mapping(uint256 => string) tokenIdLocations; // keeps track of which tokenId is located in which city
    
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
        uint256 tokenId = _tokenIdCounter.current();
        tokenIdLocations[tokenId] = "Berlin"; // all newly minted NFTs start out in Berlin
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
    function move(uint256 tokenId, uint256 locationKey) public {
        //Change locationKey of users NFT[tokenId]
    }

    /* ========== ORACLE REQUEST & FULFILL FUNCTIONS ========== */

    // Temporary function to set mock weather data per city. This should eventually be handled by Chainlink oracle and keeper
    function updateCityWeatherData(uint256 locationKey, uint24 _precipitationPastHour, int16 _temperature, uint16 _windSpeed) public onlyOwner() {
        cities[locationKey].precipitationPastHour = _precipitationPastHour;
        cities[locationKey].temperature = _temperature;
        cities[locationKey].windSpeed = _windSpeed;
    } 

    /* ========== OTHER FUNCTIONS ========== */

    function getOracleAddress() external view returns (address) {
        return chainlinkOracleAddress();
    }

    function setOracle(address _oracle) external {
        setChainlinkOracle(_oracle);
    }

    function withdrawLink() public {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }

}