//Import the compiled contract from the HelloHedera.json file
let helloHedera = require('../out/SBFactory.sol/SBFactory.json');
const bytecode = helloHedera.data.bytecode.object;

//Create a file on Hedera and store the hex-encoded bytecode
const fileCreateTx = new FileCreateTransaction()
  //Set the bytecode of the contract
  .setContents(bytecode);

//Submit the file to the Hedera test network signing with the transaction fee payer key specified with the client
const submitTx = await fileCreateTx.execute(client);

//Get the receipt of the file create transaction
const fileReceipt = await submitTx.getReceipt(client);

//Get the file ID from the receipt
const bytecodeFileId = fileReceipt.fileId;

//Log the file ID
console.log('The smart contract byte code file ID is ' + bytecodeFileId);

// Instantiate the contract instance
const contractTx = await new ContractCreateTransaction()
  //Set the file ID of the Hedera file storing the bytecode
  .setBytecodeFileId(bytecodeFileId)
  //Set the gas to instantiate the contract
  .setGas(1000000)
  //Provide the constructor parameters for the contract
  .setConstructorParameters(new ContractFunctionParameters().addString('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'));

//Submit the transaction to the Hedera test network
const contractResponse = await contractTx.execute(client);

//Get the receipt of the file create transaction
const contractReceipt = await contractResponse.getReceipt(client);

//Get the smart contract ID
const newContractId = contractReceipt.contractId;

//Log the smart contract ID
console.log('The smart contract ID is ' + newContractId);

//v2 JavaScript SDK
