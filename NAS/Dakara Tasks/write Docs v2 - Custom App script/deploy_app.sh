#!/bin/bash

# --- 0. Setup & Helpers ---
VERBOSE=false
DEBUG=false
APP_NAME=""
COMPOSE_FILE=""
ICON_URL=""

# Helper: Print only if -v is set
log_info() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo "$@"
  fi
}

# Helper: Print only if -d is set
log_debug() {
  if [[ "$DEBUG" == "true" ]]; then
    echo "🐛 DEBUG: $@" >&2
  fi
}

# Helper: Always print errors to stderr
log_error() {
  echo "❌ $@" >&2
}

usage() {
  echo "Usage: sudo $0 <APP_NAME> [options]"
  echo "Options:"
  echo "  -f, --file <path>   Path to deployment.yaml"
  echo "  -i, --icon <url>    URL for the app icon"
  echo "  -v, --verbose       Show progress messages"
  echo "  -d, --debug         Show raw API outputs and debug info"
  exit 1
}

# --- 1. Parsing Logic ---

# Check for Help or Empty args
if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# First arg is always App Name
APP_NAME="$1"
shift

# Loop through remaining args
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--file) COMPOSE_FILE="$2"; shift 2 ;;
    -i|--icon) ICON_URL="$2"; shift 2 ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -d|--debug) DEBUG=true; shift ;;
    *) log_error "Unknown argument: $1"; usage ;;
  esac
done

# Validation
if [[ -z "$COMPOSE_FILE" && -z "$ICON_URL" ]]; then
  log_error "Error: Provide --file or --icon."
  exit 1
fi

# --- 2. Deployment Logic ---
if [[ -n "$COMPOSE_FILE" ]]; then
  log_info "------------------------------------------------"
  log_info "🚀 Deploying Custom App: $APP_NAME"
  
  if [[ ! -f "$COMPOSE_FILE" ]]; then
    log_error "Error: File not found: $COMPOSE_FILE"
    exit 1
  fi

  YAML_CONTENT=$(cat "$COMPOSE_FILE")
  
  # Construct Payload
  PAYLOAD=$(jq -n \
    --arg app_name "$APP_NAME" \
    --arg yaml "$YAML_CONTENT" \
    '{
      custom_app: true,
      app_name: $app_name,
      custom_compose_config_string: $yaml
    }')

  log_debug "Payload being sent to midclt:"
  log_debug "$PAYLOAD"

  # Execute Call
  OUTPUT=$(midclt call app.create "$PAYLOAD" 2>&1)
  EXIT_CODE=$?

  if [ $EXIT_CODE -eq 0 ]; then
    log_info "✅ App created successfully."
    log_debug "API Response: $OUTPUT"
  else
    log_error "Failed to create app."
    # Only show the massive output dump if debug is on
    if [[ "$DEBUG" == "true" ]]; then
        log_error "$OUTPUT"
    else
        log_error "Use --debug to see the full API error message."
    fi
    exit 1
  fi
fi

# --- 3. Icon Injection Logic (Quote-Aware) ---
if [[ -n "$ICON_URL" ]]; then
  log_info "------------------------------------------------"
  log_info "🎨 Icon update requested for: $APP_NAME"

  BASE_PATH="/mnt/.ix-apps"
  META_FILE="${BASE_PATH}/app_configs/${APP_NAME}/metadata.yaml"

  # Wait loop (For the MAIN APP generation)
  if [[ -n "$COMPOSE_FILE" ]]; then
      log_info "   Waiting for metadata file generation..."
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
        log_info "   'metadata' block found. Injecting icon..."
        sed -i "/^[\"']\?metadata[\"']\?:/a \  \"icon\": \"$ICON_URL\"" "$META_FILE"
    else
        log_info "   'metadata' block missing. Creating it..."
        sed -i -e '$a\' "$META_FILE"
        echo "\"metadata\":" >> "$META_FILE"
        echo "  \"icon\": \"$ICON_URL\"" >> "$META_FILE"
    fi
    
    log_info "✅ Icon injected."
    log_debug "Modified file: $META_FILE"

    # Refresh Cache
    OUTPUT=$(midclt call app.metadata.generate 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
      log_info "✅ Cache refreshed. The icon should appear in the Dashboard now."
      log_debug "Metadata Refresh Response: $OUTPUT"
    else
      log_error "Failed to refresh metadata cache."
      if [[ "$DEBUG" == "true" ]]; then
          log_error "$OUTPUT"
      else
          log_error "Use --debug to see error details."
      fi
      exit 1
    fi

  else
    log_error "Metadata file not found at: $META_FILE"
    exit 1
  fi
fi

log_info "------------------------------------------------"