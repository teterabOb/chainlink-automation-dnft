// SPDX-License-Identifier: MIT
// 0xF8B8FeCd37d9aA5417Bca18AdAb3e23e4DF77456 Total supply: 10
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

// Una vez el contrato se despliega tenemos que
// ejecutar la funcion safeMint con tu address
contract DNFT is AutomationCompatibleInterface, ERC721, ERC721URIStorage  {

    uint256 counter;
    uint256 totalSupply;
    uint interval;
    uint lastTimeStamp;

    mapping (uint256 => uint256 ) nftStatus; //mapping(tokenId => status)

    //Estos valores sonn estaticos pero el NFT ira apuntando
    // a cualquier de estos valores a medida que va evolucionando
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmWXJsTejP4688dZferHR475uUPk1aXF23MJLZSUPjhvcK/state_0.json",
        "https://ipfs.io/ipfs/QmWXJsTejP4688dZferHR475uUPk1aXF23MJLZSUPjhvcK/state_1.json",
        "https://ipfs.io/ipfs/QmWXJsTejP4688dZferHR475uUPk1aXF23MJLZSUPjhvcK/state_2.json"
    ];

    constructor(uint _totalSupply, uint _interval) ERC721("dNFT", "AR131") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
        totalSupply = _totalSupply;
        counter = 0;
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
        require(counter<totalSupply,"No es posible mintear mas tokens");
        _safeMint(to, counter);
        nftStatus[counter] = 0; 
        counter ++;   
    }

    function updateAllNFTs() public {
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
    function getMinted()public view returns(uint256){
        return counter;
    }
}