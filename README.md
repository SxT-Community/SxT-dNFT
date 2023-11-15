---
title: (DRAFT) Creating a Dynamic NFT with Space and Time and ChainLink Functions
excerpt: This is the excerpt! 
hidden: True
slug: create-dynamic-nfts-with-space-and-time
category: 63728702ff90e40042fb01c2
parentDoc: 63728711a5b1f10029c22f54
---

------------------------------------------------

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
   `brew install deno`

5) Set Envars
   `npx env-enc set`

```
MUMBAI_RPC_URL = <RPC_URL for mumbai network Infura or Alchemy>
POLYGONSCAN_API_KEY = <go to polygon scan and generate an api key for free>
PRIVATE_KEY = <PK_THAT_HAS_ACCESS_TO_FUNCTIONS_BETA>
API_KEY = <GENERATE FROM sxt UI>  
API_URL = <Retrieve from SxT>
```

8) Deploy

`npx hardhat functions-deploy-consumer --network polygonMumbai --verify true`

9) Get contract address from previous step and set envar `CONTRACT_ADDRESS`
    `npx env-enc set` for CONTRACT_ADDRESS

10) Make sure you are added to the allow list from this link: https://functions.chain.link/ 
    This will create a new subscription you can use. If you create the subscription get the subid from the page.
    Make sure you add $CONTRACT_ADDRESS added as a consumer and fund the contract
    ----------
    You may need testnet tokens to create a subscription : https://mumbaifaucet.com/
    You may need testnet link tokens to fund the subscription : https://faucets.chain.link/mumbai
    ----------
    If you want a brand new subscription use this command:

    Create CL Functions Subscription and fund with link tokens

    `npx hardhat functions-sub-create --network polygonMumbai --contract $CONTRACT_ADDRESS --amount <put the amount>`

    Get sub id
    --------    
    If you want to add a new contract to subscription use this command:
    `npx hardhat functions-sub-add--network polygonMumbai --contract $CONTRACT_ADDRESS --amount <put the amount>`

11) Run request:

`npx hardhat functions-request --network polygonMumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID`

** If request fails because of missing funds run this command:
`npx hardhat functions-sub-fund --network polygonMumbai --subid $SUB_ID --amount <amount here>`


-------------------------
-------SWORD 2 ----------
-------------------------
## DYNAMIC NFT

12) Add more game telemetry to level up : 

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

13) Run request:

`npx hardhat functions-request --network polygonMumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID`

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
 

15) Run request:

`npx hardhat functions-request --network polygonMumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID`




