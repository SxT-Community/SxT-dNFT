---
title: Create Dynamic NFTs with Space & Time
excerpt: This guide will walk you through creating a dynamic NFT with Space and Time and Chainlink Functions 
hidden: True
slug: create-dynamic-nfts-with-space-and-time
category: 6424539b11d4d600114c1b48
---

## Introduction 
In this guide, we will walk you through the process of creating a dynamic NFT using Space and Time and Chainlink Functions. We will create a SwordNFT that's rating changes based on how the sword is being used in-game. More specifically, gaming telemetry in Space and Time is updated, and fed to the NFT contract using Chainlink Functions. 

[Here is an example](https://testnets.opensea.io/assets/mumbai/0x4b58475532b3362304879a147dee6ada68406c75/0) of what the NFT will look like when we're done. 

Before we get started, we should answer a couple of important questions. 

**What is a dynamic NFT (dNFT)?**

From a simple view, according to ERC721 (and ERC1155) non-fungible tokens should have a `tokenURI` function that stores a URL which will return a JSON blob of metadata for a given NFT. That blob usually contains things like a pointer to an image file, NFT name, description, etc. **A dNFT is simply an NFT where the metadata for the NFT is designed to change.** 

**But I thought NFTs weren't supposed to change!?**

There is nothing in ERC721/ERC1155 that says an NFTs metadata cannot change. The idea that an NFTs metadata shouldn't change likely comes from one specific use case involving permanent digital collectibles. While a full discussion on the topic is beyond the scope of this guide, it's important to understand that NFTs can take on many forms, and there is an increasing demand for NFTs that can evolve and/or be leveled up. Also, keep in mind that it's important to think about who (or what) can make changes to an NFT, how those changes can be made, and how long it's possible to make changes. 

## Overview  
For the guide we will go through the following high-level steps:

1) Base Setup & Config
   - Prerequisites
   - Download & install repo
   - Setup `env-enc`
2) Space & Time Setup 
   - Create Table
   - Insert Data
3) Connect SxT to Mumbai via Chainlink Functions
4) Level Up Your SwordNFT

## 1. Base Setup & Config 

> ❗ 
> Space and Time and Chainlink Functions are both in beta. It's probable that updates will be made to one or both that change how steps in this guide work. You can find us on [Discord](https://discord.gg/spaceandtimeDB) with questions. 

### Prerequisites
1) You will need beta access to Space and Time and Chainlink Functions. You can request access to [SxT beta here](https://www.spaceandtime.io/access-beta) and [Chainlink functions beta here](https://chainlinkcommunity.typeform.com/requestaccess?typeform-source=docs.chain.link).  

2) If you're new to SxT it's recommended that you start first with our [SxT Getting Started Guide](https://docs.spaceandtime.io/docs/getting-started). If you're new to Chainlink Functions, we recommend you start with their [Getting Started Guide](https://docs.chain.link/chainlink-functions/getting-started/). Having a basic understanding of how to connect to SxT and how Chainlink Functions work will set you up for success with this guide 💪 

### Setup 
1) `git clone https://github.com/SxT-Community/SxT-dNFT.git && cd SxT-DNFT` 
2) `npm install`
3) One of the packages you just install is a handy tool created by Chainlink Labs for encrypting your local environment variables. Please have a look at `npx env-enc help` to see all available commands. 
- `npx env-enc set-pw` - to set your root password
- Next, we'll use `env-enc set` to set some envars:

   `MUMBAI_RPC_URL` - RPC_URL for Mumbai network (Infura, Alchemy, etc)

   `PRIVATE_KEY` - Private key for the account/address you used to sign up for Chainlink Functions

   `ACCESS_TOKEN` - Space and Time Access Token (only valid for 30 minutes)

   `POLYGONSCAN_API_KEY` - Used to verify contracts 

   `GITHUB_API_TOKEN` - Personal access token, used by Chainlink Functions 

* Visit https://github.com/settings/tokens?type=beta and 
   - click "Generate new token"
   - Name the token and enable read & write access for Gists from the "Account permissions" drop-down menu.
   - **Do not enable any additional permissions.**
   - Click "Generate token" and copy the resulting personal access token 

___

## 2. Space & Time Setup

### Setup Data in Space and Time

> 📘 
> You can access SxT VIA the [API](https://docs.spaceandtime.io/reference/about-rest-apis) or [JDBC Driver](https://docs.spaceandtime.io/docs/jdbc-driver) 

Here's a look at the gaming telemetry table SxT we're going to create: 

Table: **GAME_TELEMETRY_ARTHUR**

| ID | GamerId | ActionType | AchievementId | collectableId | Level | ItemId | points |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 | Game Started |  |  | 1 | SwordNFt | 3 |
| 2 | 1 | Attack |  |  | 1 | SwordNFt | 3 |
| 3 | 1 | Defense |  |  | 1 | SwordNFt | 2 |
| 4 | 1 | Kill | King |  | 1 | SwordNFt | 100 |
| 5 | 1 | Attack |  |  | 1 | SwordNFt | 3 |
| 6 | 1 | Collect |  | PotionA | 2 | SwordNFt | 100 |
| 7 | 1 | Collect |  | PotionB | 2 | SwordNFt | 150 |
| 8 | 1 | Attack |  |  | 3 | SwordNFt | 9 |

-------------------------

1) First, CREATE your table: 

```SQL
CREATE TABLE TEST.GAME_TELEMETRY_ARTHUR (
    ID INTEGER,
    GamerId INTEGER,
    ActionType VARCHAR,
    AchievementId VARCHAR,
    collectableId VARCHAR,
    Level_ INTEGER,
    ItemId VARCHAR,
    Points INTEGER,
    PRIMARY KEY (ID)
) WITH "public_key=<your_biscuit_public_key>,
       access_type=public_write, 
       template=PARTITIONED, 
       atomicity=transactional"
```

> 📘 
> Please note, you will want to replace `your_biscuit_public_key` with public key used to generate the biscuit token you're sending along with this request. You'll also want to replace `TEST` with your schema name.  

2) Load Table - This is where a game would be inserting it's telemetry into SxT: 

```SQL
INSERT INTO TEST.GAME_TELEMETRY_ARTHUR (ID, GamerId, ActionType, AchievementId, collectableId, Level_, ItemId, Points)
VALUES 
    (1, 1, 'Game Started', '', '', 1, 'SwordNFt', 3),
    (2, 1, 'Attack', '', '', 1, 'SwordNFt', 3),
    (3, 1, 'Defense', '', '', 1, 'SwordNFt', 2),
    (4, 1, 'Kill', 'King', '', 1, 'SwordNFt', 100),
    (5, 1, 'Attack', '', '', 1, 'SwordNFt', 3);
```

3) View data that is loaded:

```SQL 
SELECT * from TEST.GAME_TELEMETRY_ARTHUR
```

```SQL
SELECT 
    ItemId, 
    SUM(Points),
    CASE 
        WHEN SUM(Points) BETWEEN 100 AND 150 THEN 1
        WHEN SUM(Points) BETWEEN 151 AND 300 THEN 2
        WHEN SUM(Points) > 300 THEN 3 
        ELSE ''
    END AS SWORD  
FROM TEST.GAME_TELEMETRY_ARTHUR
GROUP BY ItemId;
```

Should return:

```
ITEMID  |SUM(POINTS)|SWORD|
--------+-----------+-----+
SwordNFt|111        |1    |
```
---

## 3. Connect SxT to Mumbai via Chainlink Functions 

Now that we have our gaming telemetry table in SxT, we're going to connect everything up. The following steps were adapted from the [Chainlink Functions repo](https://github.com/smartcontractkit/functions-hardhat-starter-kit) and might be useful as a resource if you run into any issues getting Chainlink Functions setup. 

The first thing we're going to do is simulate the full interaction. This is helpful because it allows us to identify potential issues before we deploy our dNFT contract. 

1) Test/Simulate

   `npx hardhat functions-simulate --gaslimit 300000`
   
   > ❗ 
   > If the test fails, be sure your `ACCESS_TOKEN` is valid (not older than 30 minutes) in your encrypted envar file. 

2) Deploy our contract to mumbai:

   `npx hardhat functions-deploy-client --network mumbai --verify true`

3) Get the contract address from the previous step and set temporary envar: 

   `export CONTRACT_ADDRESS=<your_contract_address>`

   Now is a good time to pull up your dNFT contract on OpenSea! Just place your contract address in here: https://testnets.opensea.io/assets/mumbai/<contract_address>/0

4) Create CL Functions Subscription and fund with link tokens

   `npx hardhat functions-sub-create --network mumbai --amount 2 --contract $CONTRACT_ADDRESS`

   Get the subscription id and set a shell envar for: 
   `export SUB_ID=<CL_FUNCTIONS_SUB_ID>`

5) Run request:

   `npx hardhat functions-request --network mumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID --gaslimit 300000`

## 4. Level Up Your dNFT Sword 

Now it's time to level up your swordNFT based on a gaming telemetry update to the data in SxT. 

### Add more game telemetry to SxT (sword 2)

```SQL
INSERT INTO TEST.GAME_TELEMETRY_ARTHUR (ID, GamerId, ActionType, AchievementId, collectableId, Level_, ItemId, Points)
VALUES (6, 1, 'Collect', '', 'PotionA', 2, 'SwordNFt', 100);
```

```SQL
SELECT 
    ItemId,
    SUM(Points),
    CASE 
        WHEN SUM(Points) BETWEEN 0 AND 150 THEN 1
        WHEN SUM(Points) BETWEEN 151 AND 300 THEN 2
        WHEN SUM(Points) > 300 THEN 3 
        ELSE ''
    END AS SWORD  
FROM TEST.GAME_TELEMETRY_ARTHUR
GROUP BY ItemId;
```

### Push New Telemetry to Mumbai 

1) Test/Simulate
   `npx hardhat functions-simulate --gaslimit 300000`

2) Run request:

   `npx hardhat functions-request --network mumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID --gaslimit 300000`

   If the request fails, Double check your ACCESS_TOKEN. You need to refresh your ACCESS_TOKEN every 30 min. 

   > 🚀 Hit Open Sea and refresh the page to see your swordNFT change - https://testnets.opensea.io/assets/mumbai/<contract_address>/0

### Add More Game Telemetry to SxT (sword 3)

As the game is played, more telemetry is loaded into Space and Time! 

```SQL
INSERT INTO TEST.GAME_TELEMETRY_ARTHUR(ID, GamerId, ActionType, AchievementId, collectableId, Level_, ItemId, Points)
VALUES 
    (7, 1, 'Collect', '', 'PotionB', 2, 'SwordNFt', 150),
    (8, 1, 'Attack', '', '', 3, 'SwordNFt', 9);
```

View the insert with:

`SELECT * from TEST.GAME_TELEMETRY_ARTHUR`

Or:

```SQL
SELECT ItemId,
    SUM(Points),
    CASE 
        WHEN SUM(Points) BETWEEN 100 AND 150 THEN 1
        WHEN SUM(POINTS) BETWEEN 151 AND 300 THEN 2
        WHEN SUM(POINTS) > 300 THEN 3 
        ELSE 1 
    END AS SWORD  
FROM TEST.GAME_TELEMETRY_ARTHUR
GROUP BY ItemId;
```

## Push New Telemetry to Mumbai 

1) Test/Simulate
    `npx hardhat functions-simulate --gaslimit 300000`

2) Run the request:

   `npx hardhat functions-request --network mumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID --gaslimit 300000`

### Head back to Open Sea your level three swordNFT!
___ 


