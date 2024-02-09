#!/bin/bash
keyVaultName=$1
input=$2
hideSecrets=$3
timeout_seconds=60  # Wait for max of 1 minute for each secret retrieval

echo "$(tput -T xterm setaf 4)Getting secrets from $keyVaultName and hiding secrets: $hideSecrets"
formatted_input="$(echo "$input" | tr " " "\n" | tr ";" "\n")"
echo Formatted input "$formatted_input"

while read -r line; do
    (
        echo "::debug::Reading line: $line"
        if [ -n "$line" ]; then
            envVariableName="${line%=*}"
            secretName="${line#*=}"
            echo "Environment variable name: $envVariableName, secret name: $secretName"

            secretValue=$(timeout "$timeout_seconds" az keyvault secret show --name "$secretName" --vault-name "$keyVaultName" --query value --output tsv)

            if [ "$?" -eq 124 ]; then
                echo "::error::Secret retrieval timed out for secret: $secretName"
            elif [ "$hideSecrets" = true ]; then
                echo "::add-mask::$secretValue"
                echo "Secret name: $secretName value: $secretValue"
            else
                echo "Config name: $secretName value: $secretValue"
            fi
            echo "$envVariableName=$secretValue" >> "$GITHUB_ENV"
        else
            echo "::debug::Line is empty, skipping"
        fi
    ) &
done <<< "$formatted_input"

# Waiting for background jobs to finish with timeout
if ! wait "$!"; then
    echo "::error::Background jobs did not complete within the specified timeout"
    exit 1
fi
