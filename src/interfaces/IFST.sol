pragma solidity ^0.6.7;

interface IFST {
    /**
        @notice Caller must be owner of tokens to be smlted.
        @dev Smelt function, Smelt a new NFT token from ERC721 tokens and ERC20 tokens. Smelt rule is according to `Formula`.
        MUST revert if `_index` is not in `formula`.
        MUST revert if length of `_ids` is not the same as length of `formula` index rules.
        MUST revert if length of `_values` is not the same as length of `formula` index rules.
        MUST revert on any other error.        
        @param _ids     IDs of NFT tokens(order and length must match `formula` index rules).
        @param _values  Amounts of FT tokens(order and length must match `formula` index rules).
        @return         New Token ID of smelting.
    */
    function smelt(
        uint256 _index,
        uint256[] calldata _ids,
        uint256[] calldata _values
    ) external returns (uint256);

    // {
    // 	### smelt
    // 	1. check Formula rule by index
    //  2. transfer FTs and NFTs to address(this)
    // 	3. track FTs NFTs to new NFT
    // 	4. mint new NFT to caller
    // }

    /**
        @notice Caller must be owner of token id to be disenchated.
        @dev Disenchant function, A smelted NFT can be disenchanted into origin ERC721 tokens and ERC20 tokens recursively.
        MUST revert if  _depth is larger than the depth of _id token smleted.
        MUST revert on any other error.        
        @param _id     token ID to disenchant.
        @param _depth  recursion depth token disenchant.
    */
    function disenchat(uint256 _id, uint256 _depth) external;
    // {
    // 	### disenchant
    //  1. tranfer _id to address(this)
    // 	2. burn new NFT
    // 	3. delete track FTs NFTs to new NFT
    // 	4. transfer FNs NFTs to owner
    // }
}
