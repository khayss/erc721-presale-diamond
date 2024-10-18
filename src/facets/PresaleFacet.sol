// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPresale} from "../interfaces/IPresale.sol";
import {IERC721} from "../interfaces/IERC721.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract PresaleFacet is IPresale {
    function enforceIsActive(
        LibDiamond.DiamondStorage storage ds
    ) internal view {
        if (!ds.presaleActive) revert PresaleNotActive();
    }

    function enforcehasNotExceededMaxPurchase(
        LibDiamond.DiamondStorage storage ds
    ) internal view {
        if (ds.purchases[msgSender()] >= ds.maxPurchase)
            revert MaxPurchaseExceeded();
    }

    function msgSender() internal view returns (address) {
        return msg.sender;
    }

    function msgValue() internal view returns (uint256) {
        return msg.value;
    }

    function buyNFT(uint256 tokenId) external payable override {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        enforceIsActive(ds);
        enforcehasNotExceededMaxPurchase(ds);

        if (msgValue() != ds.presalePrice) revert IncorrectEtherAmount();
        if (IERC721(ds.nftContract).ownerOf(tokenId) != address(this))
            revert NFTNotAvailable();

        ds.purchases[msg.sender]++;
        IERC721(ds.nftContract).transferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        emit NFTPurchased(msg.sender, tokenId);
    }

    function setPresalePrice(uint256 price) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.presalePrice = price;
        emit PresalePriceUpdated(price);
    }

    function setMaxPurchase(uint256 _maxPurchase) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.maxPurchase = _maxPurchase;
        emit MaxPurchaseUpdated(ds.maxPurchase);
    }

    function setPresaleActive(bool active) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.presaleActive = active;
        emit PresaleStatusUpdated(active);
    }

    function getPresalePrice() external view override returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.presalePrice;
    }

    function getMaxPurchase() external view override returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.maxPurchase;
    }

    function isPresaleActive() external view override returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.presaleActive;
    }
}
