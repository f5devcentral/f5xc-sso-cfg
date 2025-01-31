#!/bin/bash

# ----------------------------------------------------------------------------- #
# 1. Common Functions & Constants                                               #
# ----------------------------------------------------------------------------- #
source ./constants.sh
source ./utils.sh


# ----------------------------------------------------------------------------- #
# 2. Prerequisites : Display Title, Load & Validate Environment Variables       #
# ----------------------------------------------------------------------------- #
disp_title "SSO Config Creation for XC"
load_and_validate_env_variables


# ----------------------------------------------------------------------------- #
# 3. XC SSO Configuration                                                       #
# ----------------------------------------------------------------------------- #
get_sso_config_req "$IDP_SSO_ALIAS"
ret=$?
if [ $ret -eq "$FOUND" ]; then
    disp_error_and_exit "Delete the existing SSO config to create a new config."
fi

gen_oidc_provider_payload_from_well_known_endpoints
ret=$?
if [ $ret -eq "$SUCCESS" ]; then
    create_sso_config_req "$oidc_provider_payload"
else
    get_payload_from_file "oidc_provider_create_req.json"
    create_sso_config_req "$xc_sso_payload"
fi


# ----------------------------------------------------------------------------- #
# 4. Validate XC-SSO Configuration                                              #
# ----------------------------------------------------------------------------- #
for i in {1..5}; do
    printf "Checking if XC SSO is configured ($i/5)...\n"
    get_sso_config_req "$IDP_SSO_ALIAS"
    ret=$?
    if [ $ret -eq "$FOUND" ]; then
        disp_result "SSO has been configured!"
        exit 0
    fi
    sleep 2
done
disp_error_and_exit "SSO config has not been created yet. Try GET API later to check if it is created!"

