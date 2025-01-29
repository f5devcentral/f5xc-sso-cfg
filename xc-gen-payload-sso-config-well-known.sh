#!/bin/bash

# ----------------------------------------------------------------------------- #
# 1. Common Functions & Constants                                               #
# ----------------------------------------------------------------------------- #
source ./constants.sh
source ./utils.sh


# ----------------------------------------------------------------------------- #
# 2. Prerequisites : Display Title, Load & Validate Environment Variables       #
# ----------------------------------------------------------------------------- #
disp_title "Generating SSO Config Payload w/ Well-Known Endpoints for XC"
load_and_validate_env_variables


# ----------------------------------------------------------------------------- #
# 3. Generate SSO Config Payload w/ Well-Known Endpoints                        #
# ----------------------------------------------------------------------------- #
gen_oidc_provider_payload_from_well_known_endpoints
