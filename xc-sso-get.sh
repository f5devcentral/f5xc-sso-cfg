#!/bin/bash

# ----------------------------------------------------------------------------- #
# 1. Common Functions & Constants                                               #
# ----------------------------------------------------------------------------- #
source ./constants.sh
source ./utils.sh


# ----------------------------------------------------------------------------- #
# 2. Prerequisites : Display Title, Load & Validate Environment Variables       #
# ----------------------------------------------------------------------------- #
disp_title "SSO Config Retrival for XC"
load_and_validate_env_variables


# ----------------------------------------------------------------------------- #
# 3. Get XC SSO Configuration                                                   #
# ----------------------------------------------------------------------------- #
get_sso_config_req "$IDP_SSO_ALIAS" "$API_PAYLOAD_DEBUG"
