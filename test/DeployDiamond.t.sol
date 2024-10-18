// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../src/interfaces/IDiamondCut.sol";
import "../src/facets/DiamondCutFacet.sol";
import "../src/facets/DiamondLoupeFacet.sol";
import "../src/facets/OwnershipFacet.sol";
import "../src/Diamond.sol";
import "./utils/DiamondUtils.sol";
import "../src/facets/ERC721Facet.sol";
import "../src/facets/PresaleFacet.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    ERC721Facet erc721Facet;

    /* 
    address _contractOwner,
        address _diamondCutFacet,
        address _nftContract,
        string memory _name,
        string memory _symbol,
        uint256 _presalePrice,
        uint256 _maxPurchase,
        bool _presaleActive */

    function testDeployDiamond() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        erc721Facet = new ERC721Facet();
        diamond = new Diamond(
            address(this), address(dCutFacet), address(erc721Facet), "Web3Bridge", "W3CXI", 0.1 ether, 10, true
        );
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(erc721Facet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("ERC20Facet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external override {}
}
