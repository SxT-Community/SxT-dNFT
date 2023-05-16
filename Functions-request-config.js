const fs = require("fs")

// Loads environment variables from .env file (if it exists)
require("dotenv").config()

const Location = {
  Inline: 0,
  Remote: 1,
}

const CodeLanguage = {
  JavaScript: 0,
}

const ReturnType = {
  uint: "uint256",
  uint256: "uint256",
  int: "int256",
  int256: "int256",
  string: "string",
  bytes: "Buffer",
  Buffer: "Buffer",
}

// Configure the request by setting the fields below
const requestConfig = {
  // Location of source code (only Inline is currently supported)
  codeLocation: Location.Inline,
  // Code language (only JavaScript is currently supported)
  codeLanguage: CodeLanguage.JavaScript,
  // String containing the source code to be executed
  // location of secrets (Inline or Remote)
  secretsLocation: Location.Inline,
  source: fs.readFileSync("./query-SxT-update-NFT.js").toString(),
  // Secrets can be accessed within the source code with `secrets.varName` (ie: secrets.apiKey). The secrets object can only contain string values.
  // Per-node secrets objects assigned to each DON member. When using per-node secrets, nodes can only use secrets which they have been assigned.
  perNodeSecrets: [],
  // ETH wallet key used to sign secrets so they cannot be accessed by a 3rd party
  walletPrivateKey: process.env["PRIVATE_KEY"],
  secrets: { accessToken: process.env.ACCESS_TOKEN ?? ""},
  
  // 1337 - 42
  args: ["SELECT '0xca0Da914B2DCb1b88e29c9de8Ce9F9ec04bc5874' as address FROM ETHEREUM.TRANSACTIONS limit 1","ETHEREUM.TRANSACTIONS"],

  expectedReturnType: ReturnType.string,
  // Redundant URLs which point to encrypted off-chain secrets
  secretsURLs: [],
  // Default offchain secrets object used by the `functions-build-offchain-secrets` command
  globalOffchainSecrets: {},
}

module.exports = requestConfig
