// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Functions, FunctionsClient} from "./dev/functions/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Functions Consumer contract
 * @notice This contract is a demonstration of using Functions.
 * @notice NOT FOR PRODUCTION USE
 */
contract FunctionsConsumer is FunctionsClient, ConfirmedOwner, ERC1155URIStorage {
  using Functions for Functions.Request;
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;
  bytes32 public latestRequestId;
  bytes public latestResponse;
  bytes public latestError;
  uint256 public SxTId;

  uint256 tokenId = 1;
  uint256 public constant TOTAL_SUPPLY = 10000;

  event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);
  event SxTNFTCreated(uint256 newTokenIndex,string newTokenURI, uint256 maxNewTokenSupply);
  event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

  /**
   * @notice Executes once when a contract is created to initialize state variables
   *
   * @param oracle - The FunctionsOracle contract
   */
  // https://github.com/protofire/solhint/issues/242
  // solhint-disable-next-line no-empty-blocks
  // constructor(address oracle) FunctionsClient(oracle) ConfirmedOwner(msg.sender) {}
  constructor(address oracle) FunctionsClient(oracle) ConfirmedOwner(msg.sender) ERC1155("https://cloudflare-ipfs.com/ipfs/QmYxCeAjwBiAHUztrFGt3e4ZZEV8txJdYSzVdk6YTWn84j/3") {
  }


  /**
   * @notice Send a simple request
   *
   * @param source JavaScript source code
   * @param secrets Encrypted secrets payload
   * @param args List of arguments accessible from within the source code
   * @param subscriptionId Funtions billing subscription ID
   * @param gasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @return Functions request ID
   */
  function executeRequest(
    string calldata source,
    bytes calldata secrets,
    string[] calldata args,
    uint64 subscriptionId,
    uint32 gasLimit
  ) public onlyOwner returns (bytes32) {
    Functions.Request memory req;
    req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);
    if (secrets.length > 0) {
      req.addRemoteSecrets(secrets);
    }
    if (args.length > 0) req.addArgs(args);

    bytes32 assignedReqID = sendRequest(req, subscriptionId, gasLimit);
    latestRequestId = assignedReqID;
    return assignedReqID;
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
//  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
//    latestResponse = response;
//    latestError = err;
//    emit OCRResponse(requestId, response, err);
//    SxTId = abi.decode(response, (uint256));
//    emit BatchMetadataUpdate(0, type(uint256).max);
//  }

  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    latestResponse = response;
    latestError = err;
    emit OCRResponse(requestId, response, err);
    address newOwnerAddress =  bytesToAddress(response);
    _mint(newOwnerAddress,1, 1, "");
  }

//  function mintNFT(address to) public onlyOwner {
//    _tokenIdCounter.increment();
//    require(_tokenIdCounter.current() <= TOTAL_SUPPLY, "Total supply reached");
//
//  }
  /**
   * @notice Allows the Functions oracle address to be updated
   *
   * @param oracle New oracle address
   */
  function updateOracleAddress(address oracle) public onlyOwner {
    setOracle(oracle);
  }

  function addSimulatedRequestId(address oracleAddress, bytes32 requestId) public onlyOwner {
    addExternalRequest(oracleAddress, requestId);
  }

  function bytesToAddress(bytes memory bys) private pure returns (address addr) {
    assembly {
      addr := mload(add(bys,20))
    }
  }
}
