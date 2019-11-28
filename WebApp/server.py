# Imports
import sys
sys.path.append("../")

import os
import re
import subprocess
import shlex
import requests
from flask import Flask, request, render_template, url_for, redirect, send_file
from WebApp import util, constants

# Initializing the application
app = Flask(__name__)

@app.route("/upload", methods=['GET', 'POST'])
def upload():
    if request.method == 'POST':
        if 'file' in request.files:
            file = request.files['file']
            if file.filename != '':
                # Temporarily saving the file to the Host OS.
                file.save(os.path.join(os.environ['HOME'], file.filename))

                # Copying the file to IPFS (Using the FUSE mount)
                subprocess.call(shlex.split("cp " + os.path.join(os.environ['HOME'], file.filename) + " " + os.path.join(os.environ['HOME'] + "/IPFS/", file.filename)))

                # Copying the file to IPFS (using a traditional technique)
                ret_str = subprocess.check_output(shlex.split("ipfs add " + os.path.join(os.environ['HOME'], file.filename)))
                hash = str(ret_str).split(" ")[1]
                print("server.py :: upload :: file :: ", file.filename, " :: hash :: ", hash)

                # Store the hash to a DB.
                query = "INSERT INTO " + constants.TABLE_NAME + " VALUES (\"" + file.filename +"\", \"" + hash + "\")"
                util.execute_query(query)

                # Removing the file from the Host OS
                subprocess.call(shlex.split("rm -rvf " + os.path.join(os.environ['HOME'], file.filename)))

                return render_template('success.html')
    return render_template('upload.html')

@app.route("/createAccount", methods=['GET', 'POST'])
def create_account():
    if request.method == 'POST':
        # Creating an account with the password provided.
        ret_str = subprocess.check_output(shlex.split("geth --exec 'personal.newAccount(\"" + request.form['password'] + "\")' attach http://127.0.0.1:8545")).decode("utf-8")
        print("server.py :: create_account :: ret_str :: ", str(ret_str))

        # Extracting the ID.
        id = re.findall('"([^"]*)"', ret_str)[0]
        print("server.py :: create_account :: id :: ", id)

        # Unlocking the account
        unlock_cmd = "geth --exec 'personal.unlockAccount(\"" + id + "\", \"" + request.form['password'] + "\", 0)' attach http://127.0.0.1:8545"
        unlock_cmd_output = subprocess.check_call(unlock_cmd, shell=True)
        print("server.py :: create_account :: unlock_cmd_output :: ", str(unlock_cmd_output))

        # Starting the mining process.
        mine_cmd = "geth --exec 'miner.start()' attach http://127.0.0.1:8545"
        mine_cmd_output = subprocess.check_output(shlex.split(mine_cmd))
        print("server.py :: create_account :: mine_cmd_output :: ", str(mine_cmd_output))

        return render_template('success.html')

    # Returning back
    return render_template('createAccount.html')

@app.route("/createKey", methods=['GET', 'POST'])
def create_key():
    # Creating a public and private key.
    key_comb = subprocess.check_output(shlex.split("node ../NodeFiles/crypto.js")).decode('utf-8').strip()[3:-1]
    print("server.py :: display_home :: key_comb :: ", key_comb)

    if key_comb is not None:
        keys = key_comb.split("::")

        # Storing the private key to the server.
        with open("private_key", "w") as f:
            f.write(keys[0])

    # Rendering the home page.
    return render_template('getFile.html', public_key = keys[1])

@app.route("/requestFile", methods=['GET', 'POST'])
def request_file():
    if request.method == 'POST':
        # Fetching data from the form.
        file_name = request.form['fileName']
        public_key = request.form['publicKey']
        creator_account = request.form['creatorAccount']

        # Fetching the requester account.
        requester_account = subprocess.check_output(shlex.split('geth --exec "eth.accounts[eth.accounts.length - 1]" attach http://127.0.0.1:8545')).decode('utf-8').strip()[1:-1]
        print("server.py :: request_file :: requester_account :: ", requester_account)

        # Executing the transaction.
        # 1) For sending the file details.
        transaction_cmd_1 = 'eth.sendTransaction({from: "' + requester_account + '",gas: 200000,to: "' + creator_account + '",data: web3.toHex("' + file_name + '")})'
        print("server.py :: request_file :: transaction_cmd_1 :: ", transaction_cmd_1)

        transaction_id_1 = subprocess.check_output(shlex.split("geth --exec '" + transaction_cmd_1 + "' attach http://127.0.0.1:8545")).decode("utf-8").strip()[1:-1]
        print("server.py :: request_file :: transaction_id_1 :: ", transaction_id_1)

        # 2) For sending the public key
        transaction_cmd_2 = 'eth.sendTransaction({from: "' + requester_account + '",gas: 200000,to: "' + creator_account + '",data: "0x' + public_key + '"})'
        print("server.py :: request_file :: transaction_cmd_2 :: ", transaction_cmd_2)

        transaction_id_2 = subprocess.check_output(shlex.split("geth --exec '" + transaction_cmd_2 + "' attach http://127.0.0.1:8545")).decode("utf-8").strip()[1:-1]
        print("server.py :: request_file :: transaction_id_2 :: ", transaction_id_2)

        # Sending the transaction over the web.
        params = {'transaction1': transaction_id_1, 'transaction2': transaction_id_2}
        res = requests.get(url="http://" + constants.PLACEHOLDER_IP + ":5000/transaction", params=params)
        print("server.py :: request_file :: res.text :: ", res.text)

        # Geting the private key.
        with open("private_key", "r") as f:
            private_key = f.read()

        # Decrypting the hash recieved.
        enc_ipfs_hash = res.text
        ipfs_hash = str(subprocess.check_output(shlex.split("node ../NodeFiles/decrypt.js " + private_key + " " + enc_ipfs_hash)).decode("utf-8").strip())
        print("ipfs_hash :: ", ipfs_hash)

        # Fetching the image from IPFS.
        subprocess.check_output(shlex.split("ipfs get " + ipfs_hash))
        subprocess.check_output(shlex.split("mv " + ipfs_hash + " data"))

        # Downloading the file.
        return send_file("data", as_attachment=True)

        # Returning back
    return render_template('getFile.html')

@app.route("/transaction", methods=['GET'])
def transaction():
    # Fetching transaction id from the input.
    transaction_id_1 = request.args.get('transaction1')
    transaction_id_2 = request.args.get('transaction2')

    # Fetching the file name based on the transaction id
    transaction_cmd_1 = 'eth.getTransaction("' + transaction_id_1 + '")'
    transaction_data_1 = str(subprocess.check_output(shlex.split("geth --exec '" + transaction_cmd_1 + "' attach http://127.0.0.1:8545")).decode("utf-8").strip()).replace("\n", "")
    transaction_dict_1 = {i.split(': ')[0].strip(): i.split(': ')[1] for i in transaction_data_1.split(', ')}

    file_hash = transaction_dict_1.get("input")
    file_cmd_1 = 'web3.toAscii(' + file_hash + ')'
    file_name = subprocess.check_output(shlex.split("geth --exec '" + file_cmd_1 + "' attach http://127.0.0.1:8545")).decode("utf-8").strip()[1:-1]
    print("server.py :: transaction :: file_name :: ", file_name)

    # Fetching the public key based on the transaction id
    transaction_cmd_2 = 'eth.getTransaction("' + transaction_id_2 + '")'
    transaction_data_2 = str(subprocess.check_output(shlex.split("geth --exec '" + transaction_cmd_2 + "' attach http://127.0.0.1:8545")).decode("utf-8").strip()).replace("\n", "")
    transaction_dict_2 = {i.split(': ')[0].strip(): i.split(': ')[1] for i in transaction_data_2.split(', ')}

    public_key = transaction_dict_2.get("input")[3:-1]
    print("server.py :: transaction :: public_key :: ", public_key)

    # Fetching the IPFS hash based on the file name.
    query = "SELECT file_hash FROM " + constants.TABLE_NAME + " WHERE file_name = \"" + file_name + "\""
    response = util.execute_select(query)

    ipfs_hash = response[0]
    print("server.py :: transaction :: ipfs_hash :: ", ipfs_hash)

    # Encrypting the hash with the public key.
    enc_hash = str(subprocess.check_output(shlex.split("node ../NodeFiles/encrypt.js " + public_key + " " + ipfs_hash)).decode("utf-8").strip())
    print("enc_hash :: ", enc_hash)

    return enc_hash

@app.route("/download", methods=['GET', 'POST'])
def download():
    if request.method == 'POST':
        # Getting the hash from the form.
        ipfs_hash = request.form['hash']

        # Fetching the image from IPFS.
        subprocess.check_output(shlex.split("ipfs get " + ipfs_hash))
        subprocess.check_output(shlex.split("mv " + ipfs_hash + " data"))

        return send_file("data", as_attachment=True)

    return render_template('download.html')

if __name__ == '__main__':
    util.init()
    app.run(host= '0.0.0.0')
