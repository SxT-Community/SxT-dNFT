const fs = require("fs")

// Loads environment variables from .env file (if it exists)
require("dotenv").config()
const { Location, ReturnType, CodeLanguage } = require("@chainlink/functions-toolkit")

// Configure the request by setting the fields below
const requestConfig = {
  // Location of source code (only Inline is currently supported)
  codeLocation: Location.Inline,
  // Code language (only JavaScript is currently supported)
  codeLanguage: CodeLanguage.JavaScript,
  // String containing the source code to be executed
  // location of secrets (Inline or Remote)
  secretsLocation: Location.DONHosted,
  source: fs.readFileSync("./query-SxT-update-NFT.js").toString(),
  perNodeSecrets: [],

  walletPrivateKey: process.env["PRIVATE_KEY"],
  secrets: { apiKey: process.env.API_KEY ?? ""},

  args: [
  "SELECT /*! USE ROWS */\n"+
  "CASE WHEN SUM(Points) BETWEEN 100 AND 150 THEN 1 \n" +
  "WHEN SUM(POINTS) BETWEEN 151 AND 300 THEN 2\n" +
  "WHEN SUM(POINTS) > 300 THEN 3 ELSE 1 END AS SWORD  \n" +
  "FROM SXTNFT.GAME_TELEMETRY_ARTHUR \n" +
  "GROUP BY ItemId",process.env.API_URL],

  expectedReturnType: ReturnType.uint256,
  // Redundant URLs which point to encrypted off-chain secrets
  secretsURLs: [],
  // Default offchain secrets object used by the `functions-build-offchain-secrets` command
  globalOffchainSecrets: {},
}

module.exports = requestConfig
