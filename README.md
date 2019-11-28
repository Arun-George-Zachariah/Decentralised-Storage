# Decentralised-Storage

## Setup
### IPFS Setup.
    bash ipfs_cluster_setup.sh --user <USER_NAME> --key <PPRIVATE_KEY> --hosts <HOST_LIST>
   
### Ethereum Setup.  
     bash ethereum_setup.sh --user <USER_NAME> --key <PPRIVATE_KEY> --host <HOST>

### Web App Deployment
    bash webapp_setup.sh --user <USER_NAME> --key <PPRIVATE_KEY> --host <HOST>

Environment Details:
Ubuntu 16.04.1 LTS

To create a new account 
personal.newAccount('<PASSWORD>')

To unlock the account 
personal.unlockAccount("<ACCOUNT_ID>", "<PASSWORD>", <TIME_FRAME>)

To start the mining process
miner.start()

To check the balance.
web3.fromWei(eth.getBalance("<ACCOUNT_ID>"), "ether")