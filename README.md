# f5xc-sso-cfg
SSO Configuration via F5 Distributed Cloud's Public API.

## Step 1. Prerequisites
- **Clone** this repo.
  ```bash
  git clone https://github.com/f5devcentral/f5xc-sso-cfg
  ```
- **Sign-in** as a tenant owner.
- [Generate API Tokens for My Credentials.](https://docs.cloud.f5.com/docs-v2/administration/how-tos/user-mgmt/Credentials#generate-api-tokens-for-my-credentials)


## Step 2. Set Environment Variables
- Open [.env](.env) file.
- Edit the following values per environment variable.
  | Env Variable               | Description |
  |----------------------------|-------------|
  | `API_KEY`                  | API token you generated with [this doc](https://docs.cloud.f5.com/docs-v2/administration/how-tos/user-mgmt/Credentials#generate-api-tokens-for-my-credentials) |
  | `IDP_CLIENT_ID`            | IdP client ID |
  | `IDP_CLIENT_SECRET`        | Add dummy secret if you don't need like PKCE (e.g., `dummy-sceret`) |
  | `IDP_DISABLE_USER_INFO`    | Option to disable user info endpoint |
  | `IDP_DISPLAY_NAME`         | Title of SSO login button in F5 XC Console |
  | `IDP_PROVIDER_TYPE`        | `0`:oidc(custom), `1`:google, `2`:azure, `3`:okta |
  | `IDP_SCOPES`               | OIDC scopes (e.g., `openid profile email <custom-scopes>`) |
  | `IDP_SSO_ALIAS`            | Edit one of `oidc`, `azure-oidc`, `okta-oidc`, `google`    |
  | `IDP_WELL_KNOWN_ENDPOIINT` | OIDC configuration values   |
  | `XC_FQDN`                  | F5 Distributed Cloud's Fully Qualified Domain Name (e.g., `mytenant.console.ves.volterra.io`) |

## Step 3. Config SSO for F5 Distributed

- **Create** a new SSO config
  ```bash
  bash xc-sso-create.sh
  ```

- **Update** a SSO config
  ```bash
  bash xc-sso-update.sh.sh
  ```
  > Note: This can be used for the following examples of scenarios when:
  > - Display name needs to be updated.
  > - Client secret is expired so needs to be replaced for non-PKCE option.
  > - Any IdP endpoints is changed.

- **Get** a SSO config
  ```bash
  bash xc-sso-get.sh
  ```

- **Delete** a SSO config
  ```bash
  bash xc-sso-delete.sh
  ```
