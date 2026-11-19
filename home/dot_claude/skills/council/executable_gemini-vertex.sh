#!/usr/bin/env bash
# Usage: gemini-vertex.sh <prompt-file> <output-file> [model]
# Sends the prompt file to Gemini on Vertex AI in fyxer-ai-qa, as lucien.george@fyxer.com,
# and writes the answer text to the output file. The model gets no tools, so it can only read the prompt.
set -euo pipefail

prompt_file="$1"
output_file="$2"
model="${3:-gemini-3.1-pro-preview}"
account="lucien.george@fyxer.com"
project="fyxer-ai-qa"
url="https://aiplatform.googleapis.com/v1/projects/${project}/locations/global/publishers/google/models/${model}:generateContent"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

python3 -I - "$prompt_file" "$work_dir/request.json" <<'PY'
import json, sys
prompt = open(sys.argv[1], encoding="utf-8").read()
json.dump(
    {
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {"thinkingConfig": {"thinkingLevel": "HIGH"}, "maxOutputTokens": 32768},
    },
    open(sys.argv[2], "w", encoding="utf-8"),
)
PY

token="$(gcloud auth print-access-token --account="$account")"
status="$(curl -sS --max-time 1200 -o "$work_dir/response.json" -w "%{http_code}" -X POST \
  -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" \
  "$url" --data-binary "@$work_dir/request.json")"

python3 -I - "$work_dir/response.json" "$output_file" "$status" <<'PY'
import json, sys
response_path, output_path, status = sys.argv[1:4]
try:
    data = json.load(open(response_path, encoding="utf-8"))
except ValueError:
    sys.exit(f"gemini-vertex: HTTP {status}, response was not JSON")
if "error" in data:
    sys.exit(f"gemini-vertex: HTTP {status}: {data['error'].get('message')}")
candidate = (data.get("candidates") or [{}])[0]
parts = candidate.get("content", {}).get("parts", [])
text = "".join(part.get("text", "") for part in parts if not part.get("thought"))
if not text.strip():
    sys.exit(f"gemini-vertex: empty answer (finishReason={candidate.get('finishReason')})")
open(output_path, "w", encoding="utf-8").write(text)
print(f"gemini-vertex: {data.get('modelVersion')} wrote {len(text)} chars, finishReason={candidate.get('finishReason')}")
PY
