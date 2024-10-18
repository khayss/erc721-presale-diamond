// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPresale {
    error PresaleNotActive();
    error MaxPurchaseExceeded();
    error IncorrectEtherAmount();
    error NFTNotAvailable();
    error Unauthorized();

    event NFTPurchased(address indexed buyer, uint256 indexed tokenId);
    event PresalePriceUpdated(uint256 newPrice);
    event MaxPurchaseUpdated(uint256 newMax);
    event PresaleStatusUpdated(bool isActive);

    function buyNFT(uint256 tokenId) external payable;

    function setPresalePrice(uint256 price) external;

    function setMaxPurchase(uint256 maxPurchase) external;

    function setPresaleActive(bool active) external;

    function getPresalePrice() external view returns (uint256);

    function getMaxPurchase() external view returns (uint256);

    function isPresaleActive() external view returns (bool);
}
