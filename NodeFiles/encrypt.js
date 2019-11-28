const ecies = require("eth-ecies");

var args = process.argv.slice(2);

let userPublicKey = new Buffer(args[0], 'hex');
let bufferData = new Buffer(args[1]);

let encryptedData = ecies.encrypt(userPublicKey, bufferData);

console.log(encryptedData.toString('hex'))
