# GitHub Action to fetch secrets from Azure Key Vault
This action helps you automate your workflows.
This is a replacement of [Azure/get-keyvault-secrets](https://github.com/Azure/get-keyvault-secrets).

With this action you don't have to write your own scripts for getting secrets from Azure Key Vault.

# Note
Please take into attention that this action does not install Azure CLI.
Azure CLI should be installed, so 
* if it's a GitHub-hosted runner then `az` is installed by default, but version is always used latest
* if it's a self-hosted runner, you can install `az` on your runner

Or you can always run inside a [container](https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container):
```yaml
jobs:
    runs-on: ubuntu-latest
    container:
        image: mcr.microsoft.com/azure-cli:2.41.0
```
## Dependencies on other GitHub Actions
[Azure/Login](https://github.com/Azure/login) – **optional** Login with your Azure credentials. Authentication via connection strings or keys is not supported.

# Usage
Default usage will look like this:
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: dmitriybobrovskiy/get-azure-keyvault-secrets@v1.2.0
        with:
          login_credentials: ${{ secrets.AZURE_CREDENTIALS }}
          keyvault: company-main-kv
          secrets: |
            DatabasePassword=platform-api-password
            ClientSecret=platform-api-client-secret
            AuthToken=platform-auth-token
            Serilog__WriteTo__ApplicationInsights__Args__telemetryConfiguration__ConnectionString=ai-connection-string
          configs: |
            User=platform-api-user
            ApiUrl=platform-api-url
        
      - name: Some step to consume secrets
        run: |
          echo "${{ env.User }} ${{ env.ApiUrl }}"
```
That's also working
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: dmitriybobrovskiy/get-azure-keyvault-secrets@v1.2.0
        with:
          login_credentials: ${{ secrets.AZURE_CREDENTIALS }}
          keyvault: company-main-kv
          secrets: |
            DatabasePassword=platform-api-password ClientSecret=platform-api-client-secret
        
      - name: Some step to consume secrets
        run: |
          echo "${{ env.DatabasePassword }} ${{ env.ClientSecret }}"
```
Also if you want to specify your secret names in separate file like `secrets.env` with content like this:
```env
DatabasePassword=platform-api-password
ClientSecret=platform-api-client-secret
AuthToken=platform-auth-token
Serilog__WriteTo__ApplicationInsights__Args__telemetryConfiguration__ConnectionString=ai-connection-string
```
Then you can read it like:
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: dmitriybobrovskiy/get-azure-keyvault-secrets@v1.2.0
        with:
          login_credentials: ${{ secrets.AZURE_CREDENTIALS }}
          keyvault: company-main-kv
          secrets_file_path: <path_to_the_folder>/secrets.env
          # or secrets_file_path: <path_to_the_folder>/secrets* # wildcard works as well
        
      - name: Some step to consume secrets
        run: |
          echo "${{ env.DatabasePassword }} ${{ env.AuthToken }}"
```
What is going on under the hood:
1. Login to Azure using provided credentials (if they are provided)
2. For each secret provided
   1. Go to Azure Key Vault and get the secret value
   2. Save value to GitHub environment variable

# Customizing
## inputs
| Name                | Mandatory | Description                                                                                                                                                                                                                                                                                                             |
| ------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `keyvault`          | `true`    | Key Vault where secrets will be fetched from.                                                                                                                                                                                                                                                                           |
| `login-credentials` | `false`   | Credentials to login to Azure. If not provided login action won't be performed.                                                                                                                                                                                                                                         |
| `secrets`           | `false`   | List of environment variables and key vault secret names divided by equation sign (`=`) and separated by new line. Secret value will be taken from key vault by it's name and saved to GitHub environment by name provided on the left from equation sign (`=`). Values masked out, so they will be not printed to log. |
| `configs`           | `false`   | Same as `secrets` but values are not masked out. Should be used in case if you use Azure Key Vault as a configuration store.                                                                                                                                                                                            |

# Contributing
You are absolutely welcome to contribute, create suggestions and write about issues.