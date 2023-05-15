---
title: (DRAFT) Creating a Dynamic NFT with Space and Time and ChainLink Functions
excerpt: This guide will walk you through making dynamic NFT with Space and Time and Chainlink Functions 
hidden: True
slug: create-dynamic-nfts-with-space-and-time
category: 63728702ff90e40042fb01c2
parentDoc: 63728711a5b1f10029c22f54
---

## Introduction 
In this guide, we will walk you through the process of creating a dynamic NFT using Space and Time and Chainlink Functions. We will create a SwordNFT that's rating changes based on how the sword is being used in-game. More specifically, gaming telemetry in Space and Time is updated, and fed to the NFT contract using Chainlink Functions. 

Before we get started, we should answer a couple of important question:

**What is a dynamic NFT (dNFT)?**

From a simple view, according to ERC721 (and ERC1155) non-fungible tokens should have a `tokenURI` function that stores a URL which will return a JSON blob of metadata for a given NFT. That blob usually contains things like a pointer to an image file, NFT name, description, etc. **A dNFT is simply an NFT where the metadata for the NFT is designed to change.** 

**But I thought NFTs weren't supposed to change!?**

There is nothing in ERC721/ERC1155 that says an NFTs metadata cannot change. The idea that an NFTs metadata shouldn't change likely comes from one specific use case involving permanent digital collectibles. While a full discussion on the topic is beyond the scope of this guide, it's important to understand that NFTs can take on many forms, and there is an increasing demand for NFTs that can evolve and/or be leveled up. Also, keep in mind that it's important to think about who (or what) can make changes to an NFT, how those changes can be made, and how long it's possible to make changes. 

## Overview  
For the guide we will go through the following high level steps:

1) Base Setup & Config
   - download & install repo
   - setup envars
2) Setup our game telemetry table in Space and Time
   - Connect to SxT
   - Create Table
   - Insert Data
3) Deploy NFT contract to Mumbai 
4) Connect SxT to our NFT using Chainlink Functions 
5) Level up our SwordNFT


## Base Setup & Config 

`git clone https://github.com/SxT-Community/SxT-dNFT.git` 

## DATA THAT IS LOADED INTO SPACE AND TIME TO WORK ON THE DYNAMIC NFTS

Insert game telemetry data step by step and publish data to smart contracts with chainlink functions
Here is an example how the NFT should look like after this demo: https://testnets.opensea.io/assets/mumbai/0x4b58475532b3362304879a147dee6ada68406c75/0


**game_telemetry**

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

**sword**

| SwordId | StrengthStartRange | StrengthEndRange | Type |
| --- | --- | --- | --- |
| 1 | 0 | 150 | BasicSword |
| 2 | 151 | 300 | Katana |
| 3 | 300 | 500 | Excalibur |

**game_characters**

| gameCharactersId | Achievement |
| --- | --- |
| King | 100 |
| Queen | 50 |
| Knight | 10 |
| Wizard | 200 |

**collectable_items**

| PotionA | 100 |
| --- | --- |
| PotionB | 50 |
| PotionC | 10 |
| PotionD | 200 |


------------------------------------------------
# DEMO EXCALIBUR 

## SET UP YOUR DATA

To be able to execute these SQL commands make sure you have JDBC connection set up or you can execute these commands with RESTAPI as well

* For JDBC Connection 
https://docs.spaceandtime.io/docs/jdbc-driver
* For REST API 
https://docs.spaceandtime.io/reference/about-rest-apis

-------------------------
-------CREATE TABLE -----
-------------------------

1) Create table

CREATE TABLE TEST.GAME_TELEMETRY_ARTHUR
(
ID INTEGER,
GamerId INTEGER,
ActionType VARCHAR,
AchievementId VARCHAR,
collectableId VARCHAR,
Level_ INTEGER,
ItemId VARCHAR,
Points  INTEGER,
PRIMARY KEY (ID)
) WITH "public_key=1F61FA7EE091537D0E822703432DDB0A78768C513942A422B2F459ABE46DDB8A,access_type=public_write,template=PARTITIONED, atomicity=transactional"

-------------------------
------- SWORD 1 ----------
-------------------------

2) Load Table

INSERT INTO TEST.GAME_TELEMETRY_ARTHUR(ID, GamerId, ActionType, AchievementId, collectableId, Level_, ItemId, Points)
VALUES (1, 1, 'Game Started', '', '', 1, 'SwordNFt', 3),
(2, 1, 'Attack', '', '', 1, 'SwordNFt', 3),
(3, 1, 'Defense', '', '', 1, 'SwordNFt', 2),
(4, 1, 'Kill', 'King', '', 1, 'SwordNFt', 100),
(5, 1, 'Attack', '', '', 1, 'SwordNFt', 3);

3) Check Data that is loaded:

-- SELECT * from TEST.GAME_TELEMETRY_ARTHUR

SELECT ItemId,
SUM(Points),
CASE WHEN SUM(Points) BETWEEN 100 AND 150 THEN 1
WHEN SUM(POINTS) BETWEEN 151 AND 300 THEN 2
WHEN SUM(POINTS) > 300 THEN 3 ELSE '' END AS SWORD  
FROM TEST.GAME_TELEMETRY_ARTHUR
GROUP BY ItemId;


## SET UP YOUR PROJECT

4) install packages
   `npm install`

5) Set Envars
   `npx env-enc set`

```
MUMBAI_RPC_URL = <RPC_URL for mumbai network Infura or Alchemy>
PRIVATE_KEY = <PK_THAT_HAS_ACCESS_TO_FUNCTIONS_BETA>
ACCESS_TOKEN = <GENERATE_WITH_SXTCLI from the output of -> sxtcli authenticate login --url="https://hackathon.spaceandtime.dev/" --privateKey=$privateKey --publicKey=$publicKey --userId=$userId> 
POLYGONSCAN_API_KEY = <go to polygon scan and generate an api key for free>
GITHUB_API_TOKEN = <Aquire a Github personal access token which allows reading and writing Gists.
                    Visit https://github.com/settings/tokens?type=beta and click "Generate new token"
                    Name the token and enable read & write access for Gists from the "Account permissions" drop-down menu. Do not enable any additional permissions.
                    Click "Generate token" and copy the resulting personal access token for step 4.>
```

6) Test/Simulate
`npx hardhat functions-simulate --gaslimit 300000`

7) Deploy

`npx hardhat functions-deploy-client --network mumbai --verify true`

8) Get contract address from previous step and set envar `CONTRACT_ADDRESS`
    `npx env-enc set` for CONTRACT_ADDRESS

9) Create CL Functions Subscription and fund with link tokens

`npx hardhat functions-sub-create --network mumbai --amount 2 --contract $CONTRACT_ADDRESS`

Get sub id and set envar SUB_ID

10) Run request:

`npx hardhat functions-request --network mumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID --gaslimit 300000`

If request fails, Double check your ACCESS_TOKEN. You need to refresh your ACCESS_TOKEN every 30 min


-------------------------
-------SWORD 2 ----------
-------------------------
## DYNAMIC NFT

11) Add more game telemetry to level up : 

INSERT INTO TEST.GAME_TELEMETRY_ARTHUR(ID, GamerId, ActionType, AchievementId, collectableId, Level_, ItemId, Points)
VALUES (6, 1, 'Collect', '', 'PotionA', 2, 'SwordNFt', 100);

SELECT ItemId,
SUM(Points),
CASE WHEN SUM(Points) BETWEEN 0 AND 150 THEN 1
WHEN SUM(POINTS) BETWEEN 151 AND 300 THEN 2
WHEN SUM(POINTS) > 300 THEN 3 ELSE '' END AS SWORD  
FROM TEST.GAME_TELEMETRY_ARTHUR
GROUP BY ItemId

## PUBLISH YOUR NEW DATA
Come back to this project:

12) Test/Simulate
   `npx hardhat functions-simulate --gaslimit 300000`

13) Run request:

`npx hardhat functions-request --network mumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID --gaslimit 300000`

If request fails, Double check your ACCESS_TOKEN. You need to refresh your ACCESS_TOKEN every 30 min

-------------------------
-------SWORD 3 ----------
-------------------------

14) Add more game telemetry to level up :

INSERT INTO TEST.GAME_TELEMETRY_ARTHUR(ID, GamerId, ActionType, AchievementId, collectableId, Level_, ItemId, Points)
VALUES (7, 1, 'Collect', '', 'PotionB', 2, 'SwordNFt', 150)
,(8, 1, 'Attack', '', '', 3, 'SwordNFt', 9);


SELECT * from TEST.GAME_TELEMETRY_ARTHUR


SELECT ItemId,
SUM(Points),
CASE WHEN SUM(Points) BETWEEN 100 AND 150 THEN 1
WHEN SUM(POINTS) BETWEEN 151 AND 300 THEN 2
WHEN SUM(POINTS) > 300 THEN 3 ELSE 1 END AS SWORD  
FROM TEST.GAME_TELEMETRY_ARTHUR
GROUP BY ItemId

## PUBLISH YOUR NEW DATA
Come back to this project:

15) Test/Simulate
    `npx hardhat functions-simulate --gaslimit 300000`

16) Run request:

`npx hardhat functions-request --network mumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID --gaslimit 300000`

If request fails, Double check your ACCESS_TOKEN. You need to refresh your ACCESS_TOKEN every 30 min



