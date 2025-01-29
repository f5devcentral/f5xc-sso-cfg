#!/bin/bash

# ----------------------------------------------------------------------------- #
# 1. Common Functions & Constants                                               #
# ----------------------------------------------------------------------------- #
source ./constants.sh
source ./utils.sh


# ----------------------------------------------------------------------------- #
# 2. Prerequisites : Display Title, Load & Validate Environment Variables       #
# ----------------------------------------------------------------------------- #
disp_title "SSO Config Deletion for XC"
load_and_validate_env_variables


# ----------------------------------------------------------------------------- #
# 3. Delete XC SSO Configuration                                               #
# ----------------------------------------------------------------------------- #
get_sso_config_req "$IDP_SSO_ALIAS"
ret=$?
if [ $ret -ne "$FOUND" ]; then
    disp_error_and_exit "Not found or error to delete a SSO config."
fi

get_payload_from_file "oidc_provider_delete_req.json"
delete_sso_config_req "$xc_sso_payload" "$IDP_SSO_ALIAS"

# ----------------------------------------------------------------------------- #
# 4. Validate XC-SSO Configuration                                              #
# ----------------------------------------------------------------------------- #
retry_cnt=5
for i in {1..5}; do
    printf "Checking if XC SSO is deleted ($i/5)...\n"
    get_sso_config_req "$IDP_SSO_ALIAS"
    ret=$?
    if [ $ret -ne "$FOUND" ]; then
        disp_result "SSO config has been deleted!"
        exit 0
    fi
    sleep 2
done

disp_error_and_exit "SSO config has not been deleted yet. Try GET API later to check if it is deleted!"
