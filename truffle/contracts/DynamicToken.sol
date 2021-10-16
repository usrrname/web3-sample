// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DynamicToken is Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private _tokenIds;

    /*** CONSTANTS ***/
    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant NAME = "DNFT";
    string public constant SYMBOL = "ABCD";
    uint256 private startingPrice = 500 ether;

    /*** DATATYPES ***/
    struct Token {
        string title;
    }
    Token[] private tokens;

    constructor() ERC721("DNFT", "ABCD") {}

    /*** PRIVATE FUNCTIONS ***/
    function _addressNotNull(address _to) private pure returns (bool) {
        return _to != address(0);
    }

    /// For checking approval of transfer for address _to
    function _approved(address _to, uint256 _tokenId)
        private
        view
        returns (bool)
    {
        return indexToApproved[_tokenId] == _to;
    }

    function _validate(uint256 _tokenId) internal {
        require(_exists(_tokenId), "Error, wrong/no Token id");
        require(msg.value >= indexToPrice[_tokenId], "Error, Token costs more");
    }

    /// Create Token
    function _createToken(
        string memory _title,
        string memory _tokenURI,
        address _owner,
        uint256 _price
    ) private {
        if (_price <= 0) {
            _price = startingPrice;
        }
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        mint(_owner, newTokenId, _tokenURI);
        emit Birth(newTokenId, _title, _owner);

        indexToPrice[newTokenId] = _price;
        // emits current time
        emit TimeLog(block.timestamp);
    }

    /// Check for token ownership
    function _owns(address claimant, uint256 _tokenId)
        private
        view
        returns (bool)
    {
        return claimant == indexToOwner[_tokenId];
    }

    function destroy(uint256 tokenId) internal virtual {
        _burn(tokenId);
    }

    /*** EVENTS ***/
    /// @dev The TokenSold event is fired whenever a token is sold.
    event TokenSold(
        uint256 tokenId,
        uint256 oldPrice,
        uint256 newPrice,
        address prevOwner,
        address newOwner,
        string title
    );

    /// A log of the time
    event TimeLog(uint256 time);

    /// @dev Birth event is fired whenever a new NFT comes into existence.
    event Birth(uint256 tokenId, string title, address owner);

    /// @dev Emitted when a bug is found int the contract and the contract is upgraded at a new address.
    /// In the event this happens, the current contract is paused indefinitely
    event ContractUpgrade(address newContract);

    /*** STORAGE ***/
    /// @dev A mapping from NFT IDs to the address that owns them. All tokens have
    ///  some valid owner address.
    mapping(uint256 => address) public indexToOwner;

    /// @dev A mapping from IDs to an address that has been approved to call
    ///  transferFrom().
    mapping(uint256 => address) public indexToApproved;
    // @dev A mapping from NFT IDs to the price of the token.
    mapping(uint256 => uint256) private indexToPrice;

    /*** PUBLIC FUNCTIONS ***/
    /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.

    function approve(address _to, uint256 _tokenId) public override {
        // Caller must own token.
        require(_owns(msg.sender, _tokenId));
        indexToApproved[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function mint(
        address to,
        uint256 newTokenId,
        string memory tokenURI
    ) public onlyOwner {
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        tokens[newTokenId];
    }

    // Allows someone to send ether and obtain the token
    function purchase(uint256 _tokenId, uint256 newPrice) public payable {
        _validate(_tokenId);
        address oldOwner = indexToOwner[_tokenId];
        address newOwner = msg.sender;
        uint256 sellingPrice = indexToPrice[_tokenId];
        // Making sure token owner is not sending to self
        require(oldOwner != newOwner);
        // Safety check to prevent against an unexpected 0x0 default.
        require(_addressNotNull(newOwner));
        // Making sure sent amount is greater than or equal to the sellingPrice
        require(msg.value >= sellingPrice);

        uint256 payment = uint256(
            SafeMath.div(SafeMath.mul(sellingPrice, 94), 100)
        );

        uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);

        // Update prices
        if (newPrice <= sellingPrice) indexToPrice[_tokenId] = newPrice;

        transferFrom(oldOwner, newOwner, _tokenId);

        // Pay previous tokenOwner if owner is not contract
        if (oldOwner != address(this)) {
            payable(oldOwner).transfer(payment); //(1-0.06)
        }
        emit TokenSold(
            _tokenId,
            sellingPrice,
            indexToPrice[_tokenId],
            oldOwner,
            newOwner,
            tokens[_tokenId].title
        );
        payable(msg.sender).transfer(purchaseExcess);
    }

    /// @notice Allow pre-approved user to take ownership of a token
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function takeOwnership(uint256 _tokenId) public {
        address newOwner = msg.sender;
        address oldOwner = indexToOwner[_tokenId];
        // Safety check to prevent against an unexpected 0x0 default.
        require(_addressNotNull(newOwner));
        // Making sure transfer is approved
        require(_approved(newOwner, _tokenId));
        transferFrom(oldOwner, newOwner, _tokenId);
    }

    /// For querying totalSupply of token
    function totalSupply() public view returns (uint256 total) {
        return tokens.length;
    }
}
