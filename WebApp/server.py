# Imports
import os
import re
import subprocess
import shlex
from flask import Flask, request, render_template, url_for, redirect

# Initializing the application
app = Flask(__name__)

@app.route("/")
def display_home():
    # Rendering the home page.
    return render_template('index.html')

@app.route("/account")
def display_account():
    return render_template('createAccount.html')

@app.route("/upload", methods=['POST'])
def upload():
    if 'file' in request.files:
        file = request.files['file']
        if file.filename != '':
            # Temporarily saving the file to the Host OS.
            file.save(os.path.join(os.environ['HOME'], file.filename))

            # Copying the file to IPFS (Using the FUSE mount)
            subprocess.call(shlex.split("cp " + os.path.join(os.environ['HOME'], file.filename) + " " + os.path.join(os.environ['HOME'] + "/IPFS/", file.filename)))

            # Copying the file to IPFS (using a traditional technique)
            #ret_str = subprocess.check_output(shlex.split("ipfs add " + os.path.join(os.environ['HOME'], file.filename)))
            #hash = str(ret_str).split(" ")[1]

            # To-Do: Store the hash to Ethereum.

            # Removing the file from the Host OS
            subprocess.call(shlex.split("rm -rvf " + os.path.join(os.environ['HOME'], file.filename)))
    return redirect(url_for('display_home'))

@app.route("/createAccount", methods=['POST'])
def create_account():
    if request.method == 'POST':
        # Creating an account with the password provided.
        ret_str = subprocess.check_output(shlex.split("geth --exec 'personal.newAccount(\"" + request.form['password'] + "\")' attach http://127.0.0.1:8543"))
        #ret_str = "b'\"0x621306d1f0b92344ce96d2a5fe1cf613fe8ffcdb\"\\n'"
        id = re.findall('"([^"]*)"', ret_str)[0]
        print("server.py :: create_account :: id :: ", id)

        # Unlocking the account
        subprocess.check_output(shlex.split("geth --exec 'personal.unlockAccount(\"" + id + "\", \"" + request.form['password'] + "\", \"0\""))

        # Starting the mining process.
        miner.start()
    # Returning back
    return redirect(url_for('display_account'))

if __name__ == '__main__':
    app.run(host= '0.0.0.0')
