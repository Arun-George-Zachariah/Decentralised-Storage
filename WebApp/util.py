import sys
sys.path.append("../")

import sqlite3
from WebApp import constants

def execute_query(query, db=constants.IPFS_DB):
    print("util.py :: execute_query :: query :: ", query)
    # Creating a DB connection.
    connection = sqlite3.connect(db)

    # Executing the query.
    connection.execute(query)

    # Committing the transaction.
    connection.commit()

    # Closing the connnection.
    connection.close()
    print("util.py :: execute_query :: End")

def execute_select(query, db=constants.IPFS_DB):
    print("util.py :: execute_select :: query :: ", query)
    # Creating a DB connection.
    connection = sqlite3.connect(db)

    # Executing the query.
    cursor = connection.execute(query)
    data = cursor.fetchone()
    print("util.py :: execute_select :: data :: ", data)

    # Closing the connnection.
    connection.close()

    return data

def init():
    print("util.py :: init :: Initializing the application")

    # Creating a table.
    query = "CREATE TABLE IF NOT EXISTS " + constants.TABLE_NAME + " (file_name TEXT, file_hash TEXT)"
    execute_query(query)

    print("Created Table")



