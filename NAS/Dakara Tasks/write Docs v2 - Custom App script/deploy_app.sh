#!/bin/bash

# Usage: sudo ./deploy_app.sh <APP_NAME> <PATH_TO_COMPOSE_FILE>
# or: sudo bash ./deploy_app.sh <APP_NAME> <PATH_TO_COMPOSE_FILE>

APP_NAME="$1"
COMPOSE_FILE="$2"

if [[ -z "$APP_NAME" || -z "$COMPOSE_FILE" ]]; then
  echo "Usage: sudo $0 <app_name> <path_to_compose.yaml>"
  exit 1
fi

# 1. Read the YAML file content
YAML_CONTENT=$(cat "$COMPOSE_FILE")

# 2. Construct the JSON payload
PAYLOAD=$(jq -n \
  --arg app_name "$APP_NAME" \
  --arg yaml "$YAML_CONTENT" \
  '{
    custom_app: true,
    app_name: $app_name,
    custom_compose_config_string: $yaml
  }')

echo "------------------------------------------------"
echo "Deploying Custom App: $APP_NAME"
echo "Source File: $COMPOSE_FILE"
echo "Press 'q' to exit the results view."
echo "------------------------------------------------"
sleep 1

# 3. Call the API and pipe to less
# 2>&1 ensures errors are also sent to less
# We capture the exit code of midclt using PIPESTATUS
midclt call app.create "$PAYLOAD" 2>&1 | less

# Check the exit code of the FIRST command in the pipe (midclt)
if [ ${PIPESTATUS[0]} -eq 0 ]; then
  echo "✅ Deployment command finished successfully."
else
  echo "❌ Deployment command failed. Check the output above for errors."
fi