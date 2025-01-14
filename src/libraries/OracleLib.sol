//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "../AggregatorV3Interface.sol";

/**
 * @title DSCEngine
 * @author Digvijay Deshmukh
 * @notice This library is used to check the Chainlink Oracle for stale data.
 * If a price is stale, function will revert, and render the DSCEngine unusable - this is by design
 * We want the DSCEngine to freeaze if the prices become stale
 * 
 */

library OracleLib{
    error OracleLib__StalePrice();

    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLatestRoundData(AggregatorV3Interface ChainlinkFeed) public view returns (uint80, int256, uint256, uint256, uint80) {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = ChainlinkFeed.latestRoundData();
        if (updatedAt ==0 || answeredInRound < roundId) {
            revert OracleLib__StalePrice();
        }
        uint256 secondsSince = block.timestamp - updatedAt;
        if(secondsSince > TIMEOUT) {
            revert OracleLib__StalePrice();
        }
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }

    function getTimeout(AggregatorV3Interface) public pure returns (uint256) {
        return TIMEOUT;
    }
}

