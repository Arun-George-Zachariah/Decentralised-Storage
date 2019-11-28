const ecies = require("eth-ecies");

var args = process.argv.slice(2);

let userPrivateKey = new Buffer(args[0], 'hex');
let bufferEncryptedData = new Buffer(args[1], 'hex');

let decryptedData = ecies.decrypt(userPrivateKey, bufferEncryptedData);

console.log(decryptedData.toString('utf8'));
