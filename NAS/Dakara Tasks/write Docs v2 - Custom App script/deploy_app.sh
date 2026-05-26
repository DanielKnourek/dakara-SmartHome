#!/bin/bash

# Usage: sudo ./deploy_app.sh <APP_NAME> <PATH_TO_COMPOSE_FILE> [ICON_URL]
# or: sudo bash ./deploy_app.sh <APP_NAME> <PATH_TO_COMPOSE_FILE> [ICON_URL]

APP_NAME="$1"
COMPOSE_FILE="$2"
ICON_URL="$3"

if [[ -z "$APP_NAME" || -z "$COMPOSE_FILE" ]]; then
  echo "Usage: sudo $0 <app_name> <path_to_compose.yaml> [icon_url]"
  exit 1
fi

# --- 1. Deploy the App (Standard) ---
echo "------------------------------------------------"
echo "Deploying Custom App: $APP_NAME"

YAML_CONTENT=$(cat "$COMPOSE_FILE")
PAYLOAD=$(jq -n \
  --arg app_name "$APP_NAME" \
  --arg yaml "$YAML_CONTENT" \
  '{
    custom_app: true,
    app_name: $app_name,
    custom_compose_config_string: $yaml
  }')

# Run API call and capture output
OUTPUT=$(midclt call app.create "$PAYLOAD" 2>&1)

if [ $? -eq 0 ]; then
  echo "✅ App created successfully."
else
  echo "❌ Failed to create app."
  echo "Error details:"
  echo "$OUTPUT"
  exit 1
fi

# --- 2. Inject the Icon (Corrected Placement) ---
if [[ -n "$ICON_URL" ]]; then
  echo "🎨 Icon URL provided. Injecting into metadata..."

  BASE_PATH="/mnt/.ix-apps"
  META_FILE="${BASE_PATH}/app_configs/${APP_NAME}/metadata.yaml"

  echo "   Waiting for metadata file to be generated..."
  for i in {1..10}; do
    if [ -f "$META_FILE" ]; then
      break
    fi
    sleep 1
  done

  if [ -f "$META_FILE" ]; then
    # 1. Remove any old icon line to avoid duplicates (safeguard)
    sed -i '/^\s*icon:/d' "$META_FILE"
    
    sed -i "/^metadata:/a \  \"icon\": \"$ICON_URL\"" "$META_FILE"
    
    echo "✅ Icon injected correctly under 'metadata' section."
    echo "   File modified: $META_FILE"
    echo "   (Refresh your browser to see the change)"
  else
    echo "⚠️  Metadata file not found at: $META_FILE"
    echo "   The app might be taking too long to initialize."
  fi
fi