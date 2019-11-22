const EthCrypto = require('eth-crypto');

const identity = EthCrypto.createIdentity();

console.dir(identity.privateKey);
