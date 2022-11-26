# get-azure-keyvault-secrets

Azure CLI should be installed, so 
* if it's a GitHub-hosted runner then `az` is installed, but version is always used latest
* if it's a self-hosted runner, you can install `az` on your runner

Or you can always run inside a [container](https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container):
```yaml
jobs:
    runs-on: ubuntu-latest
    container:
        image: mcr.microsoft.com/azure-cli:2.41.0
```