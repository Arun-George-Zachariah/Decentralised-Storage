window.web3 = null;
window.account = null;
window.deployContractObject = null;
window.storageContractObject = null;

$(document).ready(function(){
    console.log("Deploying the Contract");

    // Note: localhost needs to be changed with the IP.
    var web3Host = 'http://128.110.154.248',
        web3Port = '8543';

    var web3 = new Web3();
    web3.setProvider(new web3.providers.HttpProvider(web3Host + ':' + web3Port));
    if (!web3.isConnected()) {
        console.error("Ethereum - no conection to RPC server");
    } else {
        console.log("Ethereum - connected to RPC server");
    }

    var account = web3.eth.accounts[0];
    web3.eth.defaultAccount=web3.eth.accounts[0]

    var abi = [{"constant":false,"inputs":[{"name":"x","type":"string"}],"name":"set","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"}]

    var bytecode = "0x608060405234801561001057600080fd5b50610323806100206000396000f3fe608060405234801561001057600080fd5b5060043610610053576000357c0100000000000000000000000000000000000000000000000000000000900480634ed3885e146100585780636d4ce63c14610113575b600080fd5b6101116004803603602081101561006e57600080fd5b810190808035906020019064010000000081111561008b57600080fd5b82018360208201111561009d57600080fd5b803590602001918460018302840111640100000000831117156100bf57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610196565b005b61011b6101b0565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101561015b578082015181840152602081019050610140565b50505050905090810190601f1680156101885780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b80600090805190602001906101ac929190610252565b5050565b606060008054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102485780601f1061021d57610100808354040283529160200191610248565b820191906000526020600020905b81548152906001019060200180831161022b57829003601f168201915b5050505050905090565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061029357805160ff19168380011785556102c1565b828001600101855582156102c1579182015b828111156102c05782518255916020019190600101906102a5565b5b5090506102ce91906102d2565b5090565b6102f491905b808211156102f05760008160009055506001016102d8565b5090565b9056fea165627a7a7230582081d61aa68024dc5db5ed53052fe966c8ab2962b8c846008de8bd126bae253dc80029"

    var deployContractObject = {
        from: account,
        gas: 300000,
        data: bytecode
    };

    var sendDataObject = {
        from: account,
        gas: 300000,
    };

    var storageContractObject = web3.eth.contract(abi);

    window.web3 = web3;
    window.account = account;
    window.deployContractObject = deployContractObject;
    window.storageContractObject = storageContractObject;

    deployContract();
});

function getBalance() {
    window.web3.eth.getBalance(window.account, function(err, balance){
        console.log(parseFloat(window.web3.fromWei(balance, 'ether')));
    });
}

function deployContract() {
    window.currentIPFSHash = null;
    window.currentData = null;
    if (window.contractInstance) {
        console.error('Contract already deployed. Identifier: ', window.contractAddress);
        return false;
    }

    window.storageContractObject.new(window.deployContractObject, function(err, contract) {
        if (err) {
            console.error('Error deploying contract: ', err);
        } else if (contract.address) {
            var contractAddress = contract.address;
            window.contractAddress = contractAddress;
            window.contractInstance = window.storageContractObject.at(contractAddress);
            console.log('Contract deployed at address ', contractAddress);
        } else if (contract.transactionHash) {
            console.log("Waiting for contract to be deployed... Contract's transaction hash: ", contract.transactionHash);
        } else {
            console.error('Unknown error deploying contract');
        }
    });
}

function sendTransaction(data) {
    if (!window.contractInstance) {
        console.error('Make sure you deploy your contract first');
        return;
    }

    if (window.currentData == data) {
        console.error("Why would you override your contract's data with the same data, you dummy?");
        return;
    }

    window.contractInstance.set.sendTransaction(data, window.sendDataObject, function(err, result){
        if (err) {
            console.error('Error sending data: ', err);
        } else {
            window.currentData = data;
            console.log('Successfully sent data. Transaction hash: ', result);
        }
    });
}

function addFile(hash) {
    return "qwerty_hash"
}

function getData() {
    if (!window.contractInstance) {
        console.error('Make sure you deploy your contract first');
        return;
    }

    window.contractInstance.get.call(function(err, result){
        if (err) {
            console.error('Error getting data: ', err);
        } else if (result) {
            if (window.currentIPFSHash == result) {
                console.log("New data hasn't been mined yet. This is your current data: ", result);
                return;
            }

            window.currentIPFSHash = result

            console.log('File: ', result);
        } else {
            console.error('No data. Transaction not mined yet?');
        }
    });
}