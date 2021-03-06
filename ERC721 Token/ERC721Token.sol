// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

library AddressUtils {
  function isContract(
    address _addr
  ) internal view returns(bool) {
    uint256 size;

    assembly { 
        size := extcodesize(_addr)
    }
    return  size > 0;
  }
}


 interface IERC721 {
    function supportsInterface (bytes4 InterfaceID)
    external view returns(bool);
 }

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

interface ERC721 is ERC165  {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address owner);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function TransferFrom(address _from, address _to, uint256 _tokenId) external;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address operator);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

contract ERC721Token is ERC721{
  using AddressUtils for address;


    
  // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    

    constructor(string memory name, string memory symbol){
      name = _name;
      symbol = _symbol;
    }
    
    function balanceOf(address _owner) external view returns(uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[_owner];
    }
    
    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        return _owners[_tokenId];
        require(owner != address(0), "owner = zero address");
    }
    
    function safeTransferFrom(
        address _from, 
        address _to, 
        uint _tokenId, 
        bytes calldata data
    ) external override {
        address owner = ownerOf(_tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) external payable {
        _safeTransferFrom(_from, _to, _tokenId, ""); 
    }
    
    function transferFrom(address _from, address _to, uint _tokenId) external payable {
        _transfer(_from, _to, _tokenId);
    }
    
    function approve(address _approved, uint _tokenId) external payable {
        address owner = idToOwner[_tokenId];
        require(msg.sender == owner, 'Not authorized');
        idToApproved[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }
    
    function setApprovalForAll(address _operator, 
        bool _approved) 
        external 
        override 
    {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    
    function getApproved(uint _tokenId) 
        external 
        view 
        returns (address) 
    {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[_tokenId];   
    }
    
    function isApprovedForAll(address _owner, address _operator) 
        external 
        view 
        override 
        returns (bool) 
    {
        return _operatorApprovals[_owner][_operator];
    }
    
    function _safeTransferFrom(address _from, address _to, uint _tokenId, bytes memory data) internal {
       _transfer(_from, _to, _tokenId);
        
        if(_to.isContract()) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            require(retval == MAGIC_ON_ERC721_RECEIVED, 'recipient SC cannot handle ERC721 tokens');
        }
    }
    
    function _transfer(address _from, address _to, uint _tokenId) 
        internal 
        canTransfer(_tokenId) {
        ownerToTokenCount[_from] -= 1; 
        ownerToTokenCount[_to] += 1;
        idToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }
    
    modifier canTransfer(uint _tokenId) {
        address owner = idToOwner[_tokenId];
        require(owner == msg.sender 
            || idToApproved[_tokenId] == msg.sender
            || ownerToOperators[owner][msg.sender] == true, 'Transfer not authorized');
        _;
    }
}
