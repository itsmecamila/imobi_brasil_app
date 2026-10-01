#!/usr/bin/env bash
# Depois de cada edição do Claude em arquivo .dart: formata e analisa.
# Problemas encontrados voltam para o Claude (exit 2), que corrige na hora.
set -uo pipefail

file=$(jq -r '.tool_input.file_path // empty')
[[ "$file" == *.dart && -f "$file" ]] || exit 0

cd "${CLAUDE_PROJECT_DIR}"
dart format "$file" > /dev/null
if ! report=$(dart analyze --fatal-infos "$file" 2>&1); then
  echo "dart analyze encontrou problemas em $file:" >&2
  echo "$report" >&2
  exit 2
fi
