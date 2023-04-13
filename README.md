
1) install packages 
`npm install`

2) Set Envars 

`npx env-env

3) Test/Simulate 

`npx hardhat functions-simulate --gaslimit 300000`

4) Deploy

`npx hardhat functions-deploy-client --network mumbai --verify true`

Get contract address and set envar `CONTRACT_ADDRESS`

5) Create CL Functions Subscription 

`npx hardhat functions-sub-create --network mumbai --amount 2 --contract $CONTRACT_ADDRESS`

Get sub id and set envar SUB_ID

6) Run request: 

`npx hardhat functions-request --network mumbai --contract $CONTRACT_ADDRESS --subid $SUB_ID --gaslimit 300000`

