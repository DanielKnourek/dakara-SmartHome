#!/usr/bin/env python3

import os
import sys
from ldap3 import Server, Connection, ALL
from ldap3.utils.conv import escape_bytes, escape_filter_chars


# Function to print to standard error
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


###########################
### CONFIGURATION START ###
###########################

# LDAP server configuration
SERVER = "ldap://192.168.0.21:3890"

# Helper LDAP user DN and password
HELPERDN = HELPERDN="uid=ha_helper,ou=people,DC=knourek,DC=com"
HELPERPASS = "op://Private/lldap ha_helper/password"

# Timeout for LDAP operations
TIMEOUT = 3

# Base DN for LDAP search
BASEDN = "DC=knourek,DC=com"

# Attributes to retrieve during LDAP search
# examples "cn", "uid"
ATTRS = "uid"

# Base filter for LDAP search (you can add a group filter here as well)
BASE_FILTER = "(&(objectclass=person)(memberOf=cn=ha_users,ou=groups,DC=knourek,DC=com))"

#########################
### CONFIGURATION END ###
#########################

# Check if required environment variables are set
if "username" not in os.environ or "password" not in os.environ:
    eprint("Need username and password environment variables!")
    exit(1)

# Escape special characters in the username for LDAP search
safe_username = escape_filter_chars(os.environ["username"])

# LDAP filter for user search
FILTER = "(&{}({}={}))".format(BASE_FILTER, ATTRS, safe_username)

# Initialize LDAP server connection
server = Server(SERVER, get_info=ALL)
try:
    # Attempt to bind to the LDAP server with helper credentials
    conn = Connection(
        server, HELPERDN, password=HELPERPASS, auto_bind=True, raise_exceptions=True
    )
except Exception as e:
    eprint("initial bind failed: {}".format(e))
    exit(1)

# Perform LDAP search for the user
search = conn.search(BASEDN, FILTER, attributes="displayName")

# Check if the search returned any results
if len(conn.entries) > 0:
    eprint(
        "search success: username {}, result {}".format(
            os.environ["username"], conn.entries
        )
    )
    # Extract user DN and displayName from search results
    user_dn = conn.entries[0].entry_dn
    user_displayName = conn.entries[0].displayName
else:
    eprint("search for username {} yielded empty result".format(os.environ["username"]))
    exit(1)

# Unbind (close) the initial LDAP connection
conn.unbind()

# Initialize a new LDAP server connection using user credentials
server = Server(SERVER, get_info=ALL)
try:
    conn = Connection(
        server,
        user_dn,
        password=os.environ["password"],
        auto_bind=True,
        raise_exceptions=True,
    )
except Exception as e:
    eprint("bind as {} failed: {}".format(os.environ["username"], e))
    exit(1)

# Print user information and success message
print("name = {}".format(user_displayName))
print("group = system-users")

# Print success message to standard error
eprint("{} authenticated successfully".format(os.environ["username"]))

# Exit with a success status code
exit(0)
