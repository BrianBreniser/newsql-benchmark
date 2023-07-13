""" This script adds pieces of random data to the database. """
import random
import string
import time
import json
import fdb
print("Starting")

# ignore pip uppercase requirement for this script
# pylint: disable=invalid-name

fdb.api_version(720)
print("api-version 620 set")

db = fdb.open() # Do I need to specify a cluster file?
print("############## db Status:")
data = json.loads(db.get_client_status().decode())

status = 'connecting'

while status == 'connecting':
    time.sleep(1)
    status = data['Connections'][0]['Status']

print(f"db status: {status}")


AMOUNT=10
print(f"Amount: {AMOUNT}")

# Generate and store pieces of random data
for _ in range(AMOUNT):
    print("in loop")
    # Generate a random key and value. Here we are using 10-character strings,
    key = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
    value = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
    print(f"key: {key} value: {value}")

    # Store the key-value pair in the database
    db[key.encode()] = value.encode()
    print("db write done")

print(f"{AMOUNT} pieces of random data added to the database.")
db.close()
