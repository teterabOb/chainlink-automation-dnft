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

    uint public interval;
    uint public lastTimeStamp;

    enum Estado{
        Primero,
        Segundo,
        Tercero
    }

    mapping (uint256 => Estado) nftEstado;

    //Estos valores sonn estaticos pero el NFT ira apuntando
    // a cualquier de estos valores a medida que va evolucionando
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmRyokpe2C1MeCY5WontGp5Bgw7R3DKSQBZq7A7rnuTJAj/primero.json",
        "https://ipfs.io/ipfs/QmRyokpe2C1MeCY5WontGp5Bgw7R3DKSQBZq7A7rnuTJAj/segundo.json",
        "https://ipfs.io/ipfs/QmRyokpe2C1MeCY5WontGp5Bgw7R3DKSQBZq7A7rnuTJAj/tercero.json"
    ];

    constructor(uint _interval) ERC721("Solow Dynamic Buu", "SDB") {
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
        nftEstado[tokenId] = Estado.Primero;  
    }

    function updateAllNFTs() public {
        uint counter = _tokenIdCounter.current();
        for(uint i = 0; i < counter; i++){
            updateEstado(i);
        }
    }

    function updateEstado(uint256 _tokenId) public {
        uint256 currentEstado = getEstadoNFT(_tokenId);

        if(currentEstado == 0){
             nftEstado[_tokenId] = Estado.Segundo; 
        }
        else if(currentEstado == 1){
             nftEstado[_tokenId] = Estado.Tercero; 
        }
        else if(currentEstado == 2){
            nftEstado[_tokenId] = Estado.Primero;
        }
    }

    // helper functions
    function getEstadoNFT(uint256 _tokenId) public view returns(uint256){
        Estado EstadoIndex = nftEstado[_tokenId];
        return uint(EstadoIndex);
    }

    function getUriByLevel(uint256 _tokenId) public view returns(string memory){
        Estado EstadoIndex = nftEstado[_tokenId];
        return IpfsUri[uint(EstadoIndex)];
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
