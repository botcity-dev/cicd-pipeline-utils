#!/bin/bash

# Ensure correct number of arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 {deploy|update|release} -version <version> -botFile <botFilePath> -botId <botId> -type <technology> [-repository <repositoryLabel>]"
    exit 1
fi

# Parse subcommand (deploy, update, or release)
subcommand=$1
shift

# Parse remaining arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -version) version="$2"; shift ;;
        -botFile) botFile="$2"; shift ;;
        -botId) botId="$2"; shift ;;
        -type) technology="$2"; shift ;;
        -repository) repositoryLabel="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Validate required arguments based on the subcommand
case $subcommand in
    deploy|update)
        if [ -z "$version" ] || [ -z "$botFile" ] || [ -z "$botId" ] || [ -z "$technology" ]; then
            echo "Missing required arguments for $subcommand. Make sure to provide -version, -botFile, -botId, and -type."
            exit 1
        fi
        ;;
    release)
        if [ -z "$version" ] || [ -z "$botId" ]; then
            echo "Missing required arguments for release. Make sure to provide -version and -botId."
            exit 1
        fi
        ;;
    *)
        echo "Unknown subcommand: $subcommand"
        exit 1
        ;;
esac

# Set a default value for repositoryLabel if not provided
repositoryLabel=${repositoryLabel:-"DEFAULT"}

# Function to fetch secrets from environment variables
get_secrets() {
    server=$(printenv SERVER)
    login=$(printenv LOGIN)
    key=$(printenv KEY)

    if [ -z "$server" ] || [ -z "$login" ] || [ -z "$key" ]; then
        echo "Missing required secrets in environment variables."
        exit 1
    fi
}

# Function to log in to Maestro and get the access token
maestro_login() {
    local login_payload="{\"login\":\"$login\", \"key\":\"$key\"}"
    response=$(curl -s -X POST "$server/api/v2/workspace/login" -H "Content-Type: application/json" -d "$login_payload")

    # Extract access token using grep and sed (compatible with macOS)
    access_token=$(echo "$response" | grep '"accessToken"' | sed 's/.*"accessToken":"\([^"]*\)".*/\1/')
    if [ -z "$access_token" ]; then
        echo "Login failed."
        exit 1
    fi
}

# Function to deploy a bot
deploy_bot() {
    technology=$(echo "$technology" | tr '[:lower:]' '[:upper:]')

    local deploy_payload="{\"organization\":\"$login\", \"botId\":\"$botId\", \"version\":\"$version\", \"technology\":\"$technology\", \"repositoryLabel\":\"$repositoryLabel\"}"
    response=$(curl -s -w "%{http_code}" -X POST "$server/api/v2/bot" \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json" \
        -d "$deploy_payload")

    # Check for successful response using string matching
    if [[ "$response" != *"200"* ]]; then
        echo "Deploy failed. Response was: $response"
        exit 1
    fi
}

# Function to update a bot
update_bot() {
    mime_type=$(file --mime-type -b "$botFile")
    response=$(curl -s -w "%{http_code}" -X POST "$server/api/v2/bot/upload/$botId/version/$version" \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: multipart/form-data" \
        -F "file=@$botFile;type=$mime_type")

    # Check for successful response using string matching
    if [[ "$response" != *"200"* ]]; then
        echo "Update failed. Response was: $response"
        exit 1
    fi
}

# Function to release a bot
release_bot() {
    local release_payload="{\"botId\":\"$botId\", \"version\":\"$version\"}"
    response=$(curl -s -w "%{http_code}" -X POST "$server/api/v2/bot/release" \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json" \
        -d "$release_payload")

    # Check for successful response using string matching
    if [[ "$response" != *"200"* ]]; then
        echo "Release failed. Response was: $response"
        exit 1
    fi
}

# Main run function based on the subcommand
run() {
    # Step 1: Fetch secrets and log in to Maestro
    get_secrets
    maestro_login

    # Step 2: Execute the command based on the subcommand
    case $subcommand in
        deploy)
            deploy_bot
            update_bot
            echo "Deploy of $botId version $version was successful."
            ;;
        update)
            update_bot
            echo "Update of $botId version $version was successful."
            ;;
        release)
            release_bot
            echo "Release of $botId version $version was successful."
            ;;
        *)
            echo "Unknown subcommand: $subcommand"
            exit 1
            ;;
    esac
}

# Run the script
run
