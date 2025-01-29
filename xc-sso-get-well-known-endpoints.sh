#!/bin/bash

# ----------------------------------------------------------------------------- #
# 1. Common Functions & Constants                                               #
# ----------------------------------------------------------------------------- #
source ./constants.sh
source ./utils.sh


# ----------------------------------------------------------------------------- #
# 2. Prerequisites : Display Title, Load & Validate Environment Variables       #
# ----------------------------------------------------------------------------- #
disp_title "IdP Well-Known Endpoints Retrival for XC"
load_and_validate_env_variables


# ----------------------------------------------------------------------------- #
# 3. Get Well-Known Endpoints                                                   #
# ----------------------------------------------------------------------------- #
get_well_known_endpoints "$API_PAYLOAD_DEBUG"
