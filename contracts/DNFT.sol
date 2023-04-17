// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

// Una vez el contrato se despliega tenemos que
// ejecutar la funcion safeMint con tu address
contract DNFT is AutomationCompatibleInterface, ERC721, ERC721URIStorage  {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint interval;
    uint lastTimeStamp;

    mapping (uint256 => uint256 ) nftStatus; //mapping(tokenId => status)

    //Estos valores sonn estaticos pero el NFT ira apuntando
    // a cualquier de estos valores a medida que va evolucionando
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/Qme4bYrKTb6GQGawbUbtorxRQRb4xmPJ4ytdn6mvrFwHDG/state_0.json",
        "https://ipfs.io/ipfs/Qme4bYrKTb6GQGawbUbtorxRQRb4xmPJ4ytdn6mvrFwHDG/state_1.json",
        "https://ipfs.io/ipfs/Qme4bYrKTb6GQGawbUbtorxRQRb4xmPJ4ytdn6mvrFwHDG/state_2.json"
    ];

    constructor(uint _interval) ERC721("dNFT", "PdNFT") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;        
    }

    function performUpkeep(bytes calldata /* performData */) external override  {        
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;

            updateAllNFTs();            
        }        
    }

    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);      
        nftStatus[tokenId] = 0;  
    }

    function updateAllNFTs() public {
        uint counter = _tokenIdCounter.current();
        for(uint i = 0; i < counter; i++){
            updateStatus(i);
        }
    }

    function updateStatus(uint256 _tokenId) public {
        nftStatus[_tokenId] = (nftStatus[_tokenId] + 1) % IpfsUri.length;
    }

    // helper functions
    function getNFTStatus(uint256 _tokenId) public view returns(uint256){
        return nftStatus[_tokenId];
    }

    function getUriByLevel(uint256 _tokenId) public view returns(string memory){
        return IpfsUri[nftStatus[_tokenId]];
    }

    // The following functions are overrides required by Solidity.
    //
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return getUriByLevel(tokenId);
    }
}