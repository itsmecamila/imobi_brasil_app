#!/usr/bin/env bash
# Arquiva o transcript bruto da sessão em .logs/ e gera uma versão legível (.md). Privado, fora do git.
set -euo pipefail

input=$(cat)
transcript=$(jq -r '.transcript_path' <<< "$input")
session=$(jq -r '.session_id' <<< "$input")

dest="${CLAUDE_PROJECT_DIR}/.logs"
mkdir -p "$dest"
cp "$transcript" "$dest/${session}.jsonl"
jq -r -f "${CLAUDE_PROJECT_DIR}/.claude/hooks/log-legivel.jq" "$transcript" > "$dest/${session}.md"
