#!/usr/bin/env python3
import json
import sys
import os
import re

def main():
    if len(sys.argv) < 4:
        print("Usage: inject_json.py <template.html> <json_file1> [json_file2 ...] <output.html>")
        sys.exit(1)

    template_path = sys.argv[1]
    output_path = sys.argv[-1]
    json_paths = sys.argv[2:-1]

    payloads = []
    for path in json_paths:
        if not os.path.exists(path):
            print(f"Warning: File {path} not found. Skipping.")
            continue
        with open(path, 'r') as f:
            try:
                data = json.load(f)
                if isinstance(data, list):
                    payloads.extend(data)
                else:
                    payloads.append(data)
            except json.JSONDecodeError as e:
                print(f"Error decoding JSON in {path}: {e}")

    if not payloads:
        print("Error: No valid JSON payloads found.")
        sys.exit(1)

    with open(template_path, 'r') as f:
        template_content = f.read()

    # We want to replace the content inside the backticks of RESULTS_PAYLOAD
    # The line is: const RESULTS_PAYLOAD = ``;
    
    payload_json = json.dumps(payloads)
    
    # Escape characters that would break the JS template literal: ` and \ and ${
    # The order of replacements is important: backslashes first!
    payload_json_escaped = payload_json.replace('\\', '\\\\').replace('`', '\\`').replace('${', '\\${')
    
    # Use regex to find the variable assignment and replace its value inside backticks
    pattern = r'(const\s+RESULTS_PAYLOAD\s+=\s+`)(.*?)(`;)'
    
    if re.search(pattern, template_content):
        new_content = re.sub(pattern, lambda m: f"{m.group(1)}{payload_json_escaped}{m.group(3)}", template_content)
    else:
        print(f"Error: Could not find 'const RESULTS_PAYLOAD = `...`;' in {template_path}")
        sys.exit(1)

    with open(output_path, 'w') as f:
        f.write(new_content)
    
    print(f"Successfully injected {len(payloads)} JSON payloads into {output_path}")

if __name__ == "__main__":
    main()
