#!/bin/bash

# --- 1. Parsing Logic ---
APP_NAME="$1"

usage() {
  echo "Usage: sudo $0 <APP_NAME> [options]"
  echo "Options: -f (file), -i (icon)"
  exit 1
}

if [[ -z "$APP_NAME" || "$APP_NAME" == "-h" ]]; then usage; fi
shift

COMPOSE_FILE=""
ICON_URL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--file) COMPOSE_FILE="$2"; shift 2 ;;
    -i|--icon) ICON_URL="$2"; shift 2 ;;
    *) echo "❌ Unknown argument: $1"; usage ;;
  esac
done

if [[ -z "$COMPOSE_FILE" && -z "$ICON_URL" ]]; then
  echo "❌ Error: Provide --file or --icon."
  exit 1
fi

# --- 2. Deployment Logic ---
if [[ -n "$COMPOSE_FILE" ]]; then
  echo "------------------------------------------------"
  echo "🚀 Deploying Custom App: $APP_NAME"
  
  if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "❌ Error: File not found."
    exit 1
  fi

  YAML_CONTENT=$(cat "$COMPOSE_FILE")
  PAYLOAD=$(jq -n \
    --arg app_name "$APP_NAME" \
    --arg yaml "$YAML_CONTENT" \
    '{
      custom_app: true,
      app_name: $app_name,
      custom_compose_config_string: $yaml
    }')

  OUTPUT=$(midclt call app.create "$PAYLOAD" 2>&1)
  if [ $? -eq 0 ]; then
    echo "✅ App created successfully."
  else
    echo "❌ Failed to create app."
    echo "$OUTPUT"
    exit 1
  fi
fi

# --- 3. Icon Injection Logic (Quote-Aware) ---
if [[ -n "$ICON_URL" ]]; then
  echo "------------------------------------------------"
  echo "🎨 Icon update requested for: $APP_NAME"

  BASE_PATH="/mnt/.ix-apps"
  META_FILE="${BASE_PATH}/app_configs/${APP_NAME}/metadata.yaml"

  # Wait loop (For the MAIN APP)
  if [[ -n "$COMPOSE_FILE" ]]; then
      echo "   Waiting for metadata file generation..."
      for i in {1..10}; do
        if [ -f "$META_FILE" ]; then break; fi
        sleep 1
      done
  fi

  if [ -f "$META_FILE" ]; then
    # 1. Clean up: Remove any existing icon lines
    sed -i '/^\s*[\"]\?icon[\"]\?\s*:/d' "$META_FILE"
    
    # 2. Check if 'metadata' key exists (with OR without quotes)
    if grep -q "^[\"']\?metadata[\"']\?:" "$META_FILE"; then
        echo "   'metadata' block found. Injecting icon..."
        sed -i "/^[\"']\?metadata[\"']\?:/a \  \"icon\": \"$ICON_URL\"" "$META_FILE"
    else
        echo "   'metadata' block missing. Creating it..."
        sed -i -e '$a\' "$META_FILE"
        echo "\"metadata\":" >> "$META_FILE"
        echo "  \"icon\": \"$ICON_URL\"" >> "$META_FILE"
    fi
    
    echo "✅ Icon injected."
    echo "   File: $META_FILE"

    echo "🔄 Triggering App Update to refresh Dashboard cache..."
    
    TRIGGER_NAME="metadata-refresh"
    # Inlined minimal Alpine config
    TRIGGER_YAML="services:\n  metadata-refresh:\n    image: alpine"
    
        echo "Deploying dummy app to trigger cache refresh..."
    TRIGGER_PAYLOAD=$(jq -n \
      --arg name "$TRIGGER_NAME" \
      --arg yaml "$TRIGGER_YAML" \
      '{
        custom_app: true,
        app_name: $name,
        custom_compose_config_string: $yaml
      }')
    
    OUTPUT=$(midclt call app.create "$TRIGGER_PAYLOAD" 2>&1)
    echo "$OUTPUT"
    
    # --- FIXED WAIT LOOP FOR TRIGGER APP ---
    TRIGGER_META_FILE="${BASE_PATH}/app_configs/${TRIGGER_NAME}/metadata.yaml"
    echo "   Waiting for trigger app registration..."
    
    # We wait specifically for the TRIGGER app's metadata file now
    for i in {1..20}; do
      if [ -f "$TRIGGER_META_FILE" ]; then 
        echo "   ✅ Trigger app confirmed on disk."
        break 
      fi
      sleep 1
    done

    # Small safety pause to let middleware finish its write operations
    sleep 5

    echo "Deleting dummy app..."
    OUTPUT=$(midclt call app.delete "$TRIGGER_NAME" "{\"remove_images\": false}" 2>&1)
    echo "$OUTPUT"
    
    echo "✅ Cache refreshed. The icon should appear in the Dashboard now."
  else
    echo "⚠️  Metadata file not found."
  fi
fi

echo "------------------------------------------------"