# Imports
import os
from flask import Flask, request, render_template, url_for, redirect

import subprocess
import shlex

# Initializing the application
app = Flask(__name__)

@app.route("/store")
def display_home():
    # Rendering the home page.
    return render_template('index.html')

@app.route("/upload", methods=['POST'])
def upload():
    if 'file' in request.files:
        file = request.files['file']
        if file.filename != '':
            # Temporarily saving the file to the Host OS.
            file.save(os.path.join(os.environ['HOME'], file.filename))

            # Copying the file to IPFS
            subprocess.call(shlex.split("cp " + os.path.join(os.environ['HOME'], file.filename) + " " + os.path.join(os.environ['HOME'] + "/IPFS/", file.filename)))

            # Removing the file from the Host OS
            subprocess.call(shlex.split("rm -rvf " + os.path.join(os.environ['HOME'], file.filename)))
    return redirect(url_for('display_home'))

if __name__ == '__main__':
    app.run(host= '0.0.0.0')