# Converte o log bruto (.jsonl) em conversa legível: mensagens, horários (Brasília),
# recursos usados pelo Claude, recusas, erros e comandos da Camila.
def hora: .timestamp | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601 - 10800 | strftime("%d/%m %H:%M");
def uma_linha: tostring | gsub("\\s+"; " ") | .[0:100];
def resumo: (.description // .file_path // .url // .skill // .query // .questions[0].question? // .command // "") | uma_linha;

select(.type == "user" or .type == "assistant") | select(.isSidechain | not)
| hora as $h
| if .type == "user" and (.message.content | type) == "string" then
    .message.content as $c
    | if ($c | test("<bash-input>")) then
        "\n[\($h)] 💻 Camila rodou: `\($c | capture("<bash-input>(?<x>[\\s\\S]*?)</bash-input>").x)`"
      elif ($c | test("<command-name>")) then
        "\n[\($h)] ⌨️ Camila usou o comando \($c | capture("<command-name>(?<x>[^<]*)</command-name>").x)"
      elif ($c | test("^<local-command|^<system-reminder|^\\[Request interrupted|^<bash-stdout")) then empty
      else "\n[\($h)] 👩 CAMILA:\n\($c)" end
  elif .type == "user" then
    .message.content[]? | select(.type == "tool_result" and .is_error == true)
    | (if (.content | type) == "string" then .content else ([.content[]? | .text?] | join(" ")) end) as $e
    | if ($e | test("want to proceed")) then "   ❌ Camila recusou" else "   ⚠️ Erro: \($e | uma_linha)" end
  else
    .message.content[]?
    | if .type == "text" then "\n[\($h)] 🤖 CLAUDE:\n\(.text)"
      elif .type == "tool_use" then "   🔧 \(.name) — \(.input | resumo)"
      else empty end
  end
