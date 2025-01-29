#!/bin/bash

# ----------------------------------------------------------------------------- #
# 1. Common Functions & Constants                                               #
# ----------------------------------------------------------------------------- #
source ./constants.sh
source ./utils.sh


# ----------------------------------------------------------------------------- #
# 2. Prerequisites : Display Title, Load & Validate Environment Variables       #
# ----------------------------------------------------------------------------- #
disp_title "SSO Config Update for XC"
load_and_validate_env_variables


# ----------------------------------------------------------------------------- #
# 3. Update XC SSO Configuration                                                #
# ----------------------------------------------------------------------------- #
get_sso_config_req "$IDP_SSO_ALIAS"
ret=$?
if [ $ret -ne "$FOUND" ]; then
    disp_error_and_exit "Not found the existing config to update a SSO config."
fi

gen_oidc_provider_payload_from_well_known_endpoints
ret=$?
if [ $ret -eq "$SUCCESS" ]; then
    update_sso_config_req "$oidc_provider_payload" "$IDP_SSO_ALIAS"
else
    get_payload_from_file "oidc_provider_update_req.json"
    update_sso_config_req "$xc_sso_payload" "$IDP_SSO_ALIAS"
fi


# ----------------------------------------------------------------------------- #
# 4. Validate XC-SSO Configuration                                              #
# ----------------------------------------------------------------------------- #
get_sso_config_req "$IDP_SSO_ALIAS"
ret=$?
if [ $ret -ne "$FOUND" ]; then
    disp_error_and_exit "Not found or error to update a SSO config."
fi
disp_result "SSO has been updated!"
