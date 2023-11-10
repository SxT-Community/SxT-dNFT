
const sqlText = args[0]
const API = args[1]
console.log(API)
console.log(secrets.apiKey)
console.log(sqlText)

const response = await Functions.makeHttpRequest({
  url: API,
  method: "POST",
  timeout: 9000,
  headers: {
    "Content-Type": "application/json",
    "apikey": secrets.apiKey,
  },
  data: { "sqlText": sqlText }
})
const responseData = response.data
console.log(response.data)
const arrayResponse = Object.keys(responseData[0]).map((key) => `${responseData[0][key]}`);

console.log("Full response from SxT API:", response)
console.log("Value we'll send on-chain:", parseInt(arrayResponse[0]));

return Functions.encodeUint256(parseInt(arrayResponse[0]));