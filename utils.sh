#
# Common Utils
#

function disp_title() {
  local title="$1"
  local width=69
  printf "${GREEN}+-----------------------------------------------------------------------+\n"
  printf "| %-${width}s |\n" "$title"
  printf "+-----------------------------------------------------------------------+${NC}\n\n"
}

function disp_error_and_exit() {
  local error_message="$1"
  printf "${RED}+ $error_message ${NC}\n\n"
  exit 1
}

function disp_warn() {
  local warn_message="$1"
  printf "${MAGENTA}+ $warn_message ${NC}\n\n"
}

function disp_start_step() {
  local message="$1"
  printf "${CYAN}+ $message ${NC}\n"
}

function disp_result() {
  local message="$1"
  printf "${GREEN}+ $message ${NC}\n\n"
}

# Function: load_and_validate_env_variables
# Description: Load and validate environment variables for XC-SSO configuration.
# Arguments: N/A
# Returns: N/A
function load_and_validate_env_variables() {
  printf "${CYAN}+ Loading environment variables from .env file...${NC}\n"
  if [ ! -f .env ]; then
    disp_error_and_exit ".env file not found!"
  fi
  source .env

  if [ -z "$API_KEY" ]; then
    disp_error_and_exit "The API_KEY is empty or not set!"
  else
    echo "  | API_KEY                 : The API_KEY is correctly set"
  fi

  if [ -z "$IDP_CLIENT_ID" ]; then
    disp_error_and_exit "The IDP_CLIENT_ID is empty or not set!"
  else
    echo "  | IDP_CLIENT_ID           : $IDP_CLIENT_ID"
  fi

  if [ -z "$IDP_CLIENT_SECRET" ]; then
    disp_error_and_exit "The IDP_CLIENT_SECRET is empty or not set!"
  else
    echo "  | IDP_CLIENT_SECRET       : It is correctly set"
  fi

  if [ -z "$IDP_SCOPES" ]; then
    disp_error_and_exit "The IDP_SCOPES is empty or not set!"
  else
    echo "  | IDP_SCOPES              : $IDP_SCOPES"
  fi

  if [ -z "$IDP_SSO_ALIAS" ]; then
    disp_error_and_exit "The IDP_SSO_ALIAS is empty or not set!"
  else
    echo "  | IDP_SSO_ALIAS           : $IDP_SSO_ALIAS"
  fi

  if [ -z "$IDP_WELL_KNOWN_ENDPOIINT" ]; then
    disp_error_and_exit "The IDP_WELL_KNOWN_ENDPOIINT is empty or not set!"
  else
    echo "  | IDP_WELL_KNOWN_ENDPOIINT: $IDP_WELL_KNOWN_ENDPOIINT"
  fi

  if [ -z "$XC_FQDN" ]; then
    disp_error_and_exit "The XC_FQDN is empty or not set!"
  else
    echo "  | XC_FQDN                 : $XC_FQDN"
  fi

  if [ -z "$XC_TENANT_NAME" ]; then
    disp_warn "The XC_TENANT_NAME is empty or not set!"
  else
    echo "  | XC_TENANT_NAME          : $XC_TENANT_NAME"
  fi

  disp_result "Loaded environment variables from .env file!"
}


# Function: get_payload_from_file
# Description: Get API payload from a JSON file
# Arguments:
#   $1: JSON payload file
# Returns:
#   $xc_sso_payload: JSON payload
function get_payload_from_file() {
  local json_file="$1"
  if [ -z "$json_file" ]; then
    disp_error_and_exit "The argument of json_file is empty or not set!"
  fi
  xc_sso_payload=$(cat "$json_file")
}


# Function: disp_status_code_resp_body
# Description: Display status_code and payload from the API response
# Arguments: N/A
#   $1: The status code from the API response
#   $2: API response body
#   $3: Option to debug response body
# Returns: N/A
function disp_status_code_resp_body() {
  local status_code="$1"
  local resp_body="$2"
  local resp_body_debug="$3"

  echo "  | HTTP Status Code: $status_code"
  if [[ $resp_body_debug == 1 ]]; then
    echo "  | Response Body   : "
    echo "$resp_body" | sed 's/^/    /'
  fi
}


# Function: create_sso_config_req
# Description: Request to create SSO config in XC via POST API.
# Arguments:
#   $1: Payload to create a SSO config
#   $2: Option to debug response body
# Returns: N/A
function create_sso_config_req() {
  disp_start_step "Creating SSO configuration..."
  local payload="$1"
  local res_body_debug="$2"

  # Make the POST request and capture the response and HTTP status code
  local url="https://$XC_FQDN$URI_OIDC_PROVIDERS"
  echo "  | POST -X $url"
  local response=$(curl -s -w "%{http_code}"  \
    -k -X POST "$url"                         \
    -H "Authorization: APIToken $API_KEY"     \
    -H "Content-Type: application/json"       \
    -H "Accept: application/json"             \
    -d "$payload")

  local status_code="${response: -3}"
  local response_body="${response:0:${#response}-3}"
  disp_status_code_resp_body "$status_code", "$response_body", "$res_body_debug"

  # Check if the request was successful (status code 2xx)
  if [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
    err=$(echo "$response_body" | jq -r '.err')
    if [[ "$err" == "EEXISTS" ]]; then
      disp_error_and_exit "SSO configuration already exists!"
    elif [[ "$err" == "EOK" ]]; then
      disp_result "Requested to create XC SSO config!"
    else
      disp_result "err: $err"
    fi
  else
    disp_error_and_exit "Failed to create SSO config!"
  fi
}


# Function: update_sso_config_req
# Description: Request to update SSO config in XC via POST API.
# Arguments:
#   $1: Payload to update XC SSO config
#   $2: The alias of SSO config to be updated. (e.g., oidc, azure-oidc, okta-oidc, google)
#   $3: Option to debug response body
# Returns: N/A
function update_sso_config_req() {
  disp_start_step "Updating SSO configuration..."

  # Validate the arguments
  local payload="$1"
  local alias="$2"
  if [ -z "$alias" ]; then
    disp_error_and_exit "The argument of alias is empty or not set!"
  fi
  local res_body_debug="$3"

  # Make the POST request and capture the response and HTTP status code
  local url="https://$XC_FQDN$URI_OIDC_PROVIDERS/$alias"
  echo "  | POST -X $url"
  local response=$(curl -s -w "%{http_code}"  \
    -k -X POST "$url"                         \
    -H "Authorization: APIToken $API_KEY"     \
    -H "Content-Type: application/json"       \
    -H "Accept: application/json"             \
    -d "$payload") 

  local status_code="${response: -3}"
  local response_body="${response:0:${#response}-3}"
  disp_status_code_resp_body "$status_code", "$response_body", "$res_body_debug"

  # Check if the request was successful (status code 2xx)
  if [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
    err=$(echo "$response_body" | jq -r '.err')
    if [[ "$err" == "EOK" ]]; then
      disp_result "Requested to update XC SSO config!"
    else
      disp_result "err: $err"
    fi
  else
    disp_error_and_exit "Failed to update SSO config!"
  fi
}

# Function: get_sso_config_req
# Description: Request to get SSO config in XC via GET API.
# Arguments:
#   $1: The alias of SSO config to be retrieved. (e.g., oidc, azure-oidc, okta-oidc, google)
#   $2: Option to debug response body
# Returns:
#   Result of whether the SSO config is found or not.
function get_sso_config_req() {
  disp_start_step "Retrieving SSO configuration..."

  # Validate the arguments
  local alias="$1"
  if [ -z "$alias" ]; then
    disp_error_and_exit "The argument of alias is empty or not set!"
  fi
  local res_body_debug="$2"

  # Make the GET request and capture the response and HTTP status code
  local url="https://$XC_FQDN$URI_OIDC_PROVIDERS/$alias"
  local response=$(curl -s -w "%{http_code}"  \
    -k -X GET "$url"                          \
    -H "Authorization: APIToken $API_KEY"     \
    -H "Accept: application/json")

  local status_code="${response: -3}"
  local response_body="${response:0:${#response}-3}"
  disp_status_code_resp_body "$status_code", "$response_body", "$res_body_debug"

  if [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
    object=$(echo "$response_body" | jq -r '.object')
    if [[ "$object" == null ]]; then
      disp_result "XC SSO config not found!"
    else
      disp_result "XC SSO config has been retrieved!"
      return "$FOUND"
    fi
  else
    disp_error_and_exit "Failed to get SSO config!"
  fi
  return "$NOT_FOUND"
}

# Function: delete_sso_config_req
# Description: Request to delete SSO config in XC via POST API.
# Arguments:
#   $1: Payload for the deletion request
#   $2: The alias of SSO config to be deleted. (e.g., oidc, azure-oidc, okta-oidc, google)
#   $3: Option to debug response body
# Returns: N/A
function delete_sso_config_req() {
  disp_start_step "Deleting SSO configuration..."

  # Validate the arguments
  local payload="$1"
  local alias="$2"
  if [ -z "$alias" ]; then
    disp_error_and_exit "The argument of alias is empty or not set!"
  fi
  local res_body_debug="$3"

  # Make the POST request and capture the response and HTTP status code
  local url="https://$XC_FQDN$URI_OIDC_PROVIDER/$alias/delete"
  echo "  | POST -X $url"
  local response=$(curl -s -w "%{http_code}"  \
    -k -X POST "$url"                         \
    -H "Authorization: APIToken $API_KEY"     \
    -H "Accept: application/json"             \
    -d "$payload")

  local status_code="${response: -3}"
  local response_body="${response:0:${#response}-3}"
  disp_status_code_resp_body "$status_code", "$response_body", "$res_body_debug"

  # Check if the request was successful (status code 2xx)
  if [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
    err=$(echo "$response_body" | jq -r '.err')
    if [[ "$err" != EOK ]]; then
      disp_error_and_exit "SSO configuration has not been deleted!"
    fi
    disp_result "Requested to delete XC SSO config!"
  else
    disp_error_and_exit "Failed to delete SSO config!"
  fi
}

# Function: get_well_known_endpoints
# Description: Request to get IdP well-known endpoints.
# Arguments:
#   $1: Option to debug response body
# Returns:
#   $well_known_res_body: respons body from the IdP well-known endpoints
function get_well_known_endpoints() {
  disp_start_step "Retrieving IdP's well-known endpoints..."

  # Validate IDP_WELL_KNOWN_ENDPOIINT
  if [ -z "$IDP_WELL_KNOWN_ENDPOIINT" ]; then
    return "$NOT_FOUND"
  fi

  # Validate the argument
  local res_body_debug="$1"

  # Make the GET request and capture the response and HTTP status code
  local url="$IDP_WELL_KNOWN_ENDPOIINT"
  local response=$(curl -s -w "%{http_code}"  \
    -k -X GET "$url"                          \
    -H "Accept: application/json")

  local status_code="${response: -3}"
  well_known_res_body="${response:0:${#response}-3}"
  disp_status_code_resp_body "$status_code", "$well_known_res_body", "$res_body_debug"

  if [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
    local authz_endpoint=$(echo "$well_known_res_body" | jq -r '.authorization_endpoint')
    if [ -z "$authz_endpoint" ]; then
      disp_error_and_exit "Failed to get authz_endpoint!"
    else
      disp_result "IdP well-known endpoints has been retrieved!"
    fi
  else
    disp_error_and_exit "Failed to get IdP well-known endpoints!"
  fi
  return "$FOUND"
}


# Function: gen_oidc_provider_payload_from_well_known_endpoints
# Description: Generate a payload of oidc_provider obj w/ well-known endpoint
# Arguments: N/A
# Returns:
#   $oidc_provider_payload: payload of the oidc_provider object
function gen_oidc_provider_payload_from_well_known_endpoints() {
  # Get main endpoints by calling API to the IdP's well-known endpoints
  get_well_known_endpoints # "$API_PAYLOAD_DEBUG"
  ret=$?
  if [ $ret -eq "$NOT_FOUND" ]; then
      return "$FAIL"
  fi

  # Generate a payload of the oidc_provider object
  disp_start_step "Generating a payload of the oidc_provider object..."

  local authorization_endpoint=$(echo "$well_known_res_body" | jq -r '.authorization_endpoint')
  local token_endpoint=$(echo "$well_known_res_body" | jq -r '.token_endpoint')
  local end_session_endpoint=$(echo "$well_known_res_body" | jq -r '.end_session_endpoint')
  local issuer=$(echo "$well_known_res_body" | jq -r '.issuer')
  local jwks_uri=$(echo "$well_known_res_body" | jq -r '.jwks_uri')

  # Set spec type for an oidc_provider object
  local spec_type="oidc_v10_spec_type"
  case "$IDP_SSO_ALIAS" in
    "azure_oidc")
      spec_type="azure_oidc_spec_type"
      ;;
    "okta_oidc")
      spec_type="okta_oidc_spec_type"
      ;;
    "google")
      spec_type="google_oidc_spec_type"
      ;;
  esac

  oidc_provider_payload='{
    "name": "'$IDP_SSO_ALIAS'",
    "namespace": "system",
    "spec": {
      "provider_type": '$IDP_PROVIDER_TYPE',
      "'$spec_type'": {
        "display_name": "'$IDP_DISPLAY_NAME'",
        "client_id": "'$IDP_CLIENT_ID'",
        "client_secret": "'$IDP_CLIENT_SECRET'",
        "default_scopes": "'$IDP_SCOPES'",
        "authorization_url": "'$authorization_endpoint'",
        "token_url": "'$token_endpoint'",
        "logout_url": "'$end_session_endpoint'",
        "backchannel_logout": true,
        "disable_user_info": '$IDP_DISABLE_USER_INFO',
        "issuer": "'$issuer'",
        "jwks_uri": "'$jwks_uri'",
        "validate_signatures": true
      }
    }
  }'
  printf "  $oidc_provider_payload\n"
  disp_result "Generated a payload of the oidc_provider object..."
  return "$SUCCESS"
}
