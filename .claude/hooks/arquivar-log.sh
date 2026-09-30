#!/usr/bin/env bash
# Arquiva o transcript bruto da sessão em .logs/ (privado, fora do git).
set -euo pipefail

input=$(cat)
transcript=$(jq -r '.transcript_path' <<< "$input")
session=$(jq -r '.session_id' <<< "$input")

dest="${CLAUDE_PROJECT_DIR}/.logs"
mkdir -p "$dest"
cp "$transcript" "$dest/${session}.jsonl"
