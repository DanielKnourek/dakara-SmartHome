#!/usr/bin/env python3

import argparse
import sys
import json
import time
import os
import re

# Import TrueNAS Middleware Client directly
# This is available in the system python on TrueNAS Scale
try:
    from truenas_api_client import Client
except ImportError:
    print("❌ Error: Could not import 'middlewared'. Are you running this on TrueNAS Scale?", file=sys.stderr)
    sys.exit(1)
    
# --- 1. Setup & Helper Functions ---

def setup_logging(args):
    """Simple logging wrapper based on verbosity flags."""
    def log_info(msg):
        if args.verbose:
            print(msg)

    def log_debug(msg):
        if args.debug:
            print(f"🐛 \033[0;31mDEBUG:\033[0m {msg}", file=sys.stderr)

    def log_error(msg):
        print(f"❌ \033[0;31m{msg}\033[0m", file=sys.stderr)

    return log_info, log_debug, log_error

def parse_arguments():
    parser = argparse.ArgumentParser(description="Deploy Custom Apps on TrueNAS Scale via Python API")
    parser.add_argument("app_name", help="Name of the application")
    parser.add_argument("-f", "--file", help="Path to deployment.yaml", required=False)
    parser.add_argument("-i", "--icon", help="URL for the app icon", required=False)
    parser.add_argument("-v", "--verbose", action="store_true", help="Show progress messages")
    parser.add_argument("-d", "--debug", action="store_true", help="Show raw API outputs and debug info")
    
    args = parser.parse_args()
    
    if not args.file and not args.icon:
        parser.error("You must provide either --file or --icon.")
        
    return args

# --- 2. Core Logic ---

def deploy_app(client, args, log_info, log_debug, log_error):
    if not args.file:
        return

    log_info("------------------------------------------------")
    log_info(f"🚀 Deploying Custom App: {args.app_name}")

    if not os.path.exists(args.file):
        log_error(f"Error: File not found: {args.file}")
        sys.exit(1)

    try:
        with open(args.file, 'r') as f:
            yaml_content = f.read()
    except Exception as e:
        log_error(f"Failed to read file: {e}")
        sys.exit(1)

    # Construct the payload dictionary
    # We pass this directly to the Python API, avoiding CLI limits entirely
    payload = {
        "custom_app": True,
        "app_name": args.app_name,
        "custom_compose_config_string": yaml_content
    }

    log_debug(f"Payload keys: {list(payload.keys())}")
    log_debug(f"YAML content length: {len(yaml_content)} characters")

    try:
        # The Magic: Direct API Call
        # This is equivalent to `midclt call app.create` but faster and safer
        result = client.call('app.create', payload)
        
        log_info("✅ App created successfully.")
        log_debug(f"API Response: {json.dumps(result, indent=2)}")

    except ClientException as e:
        log_error("Failed to create app.")
        
        # Check if the error object has a 'error' attribute or string representation
        error_msg = str(e)
        
        if args.debug:
            log_error(f"Full Exception: {error_msg}")
            # Try to print trace if available in the exception
            if hasattr(e, 'trace'):
                 log_debug(f"Trace: {e.trace}")
        else:
            # Try to extract a clean reason from standard middleware error format
            # Format usually: "[EFAULT] reason"
            if "[EFAULT]" in error_msg:
                clean_msg = error_msg.split("[EFAULT]")[-1].strip()
                log_error(f"Reason: {clean_msg}")
            else:
                log_error(f"Reason: {error_msg}")
            log_error("Use --debug to see full details.")
        sys.exit(1)

def inject_icon(client, args, log_info, log_debug, log_error):
    if not args.icon:
        return

    log_info("------------------------------------------------")
    log_info(f"🎨 Icon update requested for: {args.app_name}")

    base_path = "/mnt/.ix-apps/app_configs"
    meta_file = os.path.join(base_path, args.app_name, "metadata.yaml")

    # Wait loop logic
    if args.file:
        log_info("   Waiting for metadata file generation...")
        for _ in range(10):
            if os.path.exists(meta_file):
                break
            time.sleep(1)

    if not os.path.exists(meta_file):
        log_error(f"Metadata file not found at: {meta_file}")
        log_error("App might have failed to deploy or path is incorrect.")
        sys.exit(1)

    # Robust text manipulation instead of fragile sed
    # We read all lines, modify in memory, and write back
    try:
        with open(meta_file, 'r') as f:
            lines = f.readlines()

        new_lines = []
        metadata_found = False
        icon_injected = False

        # Filter out existing icon lines
        lines = [line for line in lines if not re.match(r'^\s*["\']?icon["\']?\s*:', line)]

        # Scan for metadata block
        for line in lines:
            new_lines.append(line)
            if re.match(r'^["\']?metadata["\']?:', line):
                metadata_found = True
                # Inject icon immediately after metadata tag
                new_lines.append(f'  "icon": "{args.icon}"\n')
                icon_injected = True

        # If metadata block wasn't found, append it to the end
        if not metadata_found:
            log_info("   'metadata' block missing. Creating it...")
            if new_lines and not new_lines[-1].endswith('\n'):
                 new_lines.append('\n')
            new_lines.append('"metadata":\n')
            new_lines.append(f'  "icon": "{args.icon}"\n')
        else:
             log_info("   'metadata' block found. Injecting icon...")

        # Write back changes
        with open(meta_file, 'w') as f:
            f.writelines(new_lines)
            
        log_info("✅ Icon injected.")
        log_debug(f"Modified file: {meta_file}")

        # Refresh Cache via API
        client.call('app.metadata.generate')
        log_info("✅ Cache refreshed.")

    except Exception as e:
        log_error(f"Failed to update icon: {e}")
        if args.debug:
            import traceback
            traceback.print_exc()
        sys.exit(1)

# --- 3. Main Execution ---

def main():
    args = parse_arguments()
    log_info, log_debug, log_error = setup_logging(args)

    # Initialize Middleware Client
    # Using 'with' ensures the connection closes properly
    try:
        with Client() as c:
            deploy_app(c, args, log_info, log_debug, log_error)
            inject_icon(c, args, log_info, log_debug, log_error)
            
            log_info("------------------------------------------------")
            
    except Exception as e:
        log_error(f"Unexpected connection error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()