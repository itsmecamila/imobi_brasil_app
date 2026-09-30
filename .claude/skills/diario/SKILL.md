---
name: diario
description: Atualiza o diário do dia em docs/diario/AAAA-MM-DD.md com linha do tempo, decisões, perguntas, aprendizados, recursos usados, verificação e erros. Use ao fim de cada bloco de trabalho (commit, decisão, problema resolvido) ou quando a Camila digitar /diario.
argument-hint: "[palavras da Camila para registrar literalmente]"
---

# Diário do projeto

O diário é a matéria-prima para a Camila reler o processo e escrever, com as palavras dela, a seção "Harness e estratégia" do README. Ele é privado (fora do git).

## Fontes (nesta ordem)
1. O diário do dia, se já existir: `docs/diario/AAAA-MM-DD.md`.
2. O log legível da sessão: o `.md` mais recente em `.logs/`. Use o `.jsonl` de mesmo nome quando precisar de detalhes (saída completa de comandos, erros).
3. `git log --format='%h %ad %s' --date=format:%H:%M` para os commits do dia.
4. `docs/PROGRESSO.md` para a fase e o percentual.

## Regras
1. **Atualize, não duplique:** acrescente só o que aconteceu desde a última atualização.
2. **Só fatos que estão no log.** Não embeleze nem invente o raciocínio da Camila. Quando o argumento dela não estiver registrado, escreva `_(Camila: complete com o seu argumento)_`.
3. **Palavras da Camila:** se ela passar texto junto com o comando (`$ARGUMENTS`), registre-o literalmente, entre aspas, na seção adequada.
4. **"✍️ Espaço da Camila" é só dela:** crie a seção vazia, mas nunca escreva nem altere o conteúdo.
5. **Horários de Brasília** (UTC−3), no formato HH:MM. Use `~` quando o horário for aproximado.
6. **Ideias** estacionadas também vão para `docs/IDEIAS.md`.
7. **Dia do prazo:** 30/09 = dia 1 … 05/10 = dia 6.
8. **Ao terminar**, avise em uma linha: `📓 diário atualizado: <seções alteradas>`.
9. **Mudança de template:** ao reformatar diários antigos, preserve todo o conteúdo existente, em especial o Espaço da Camila, que deve ser mantido palavra por palavra. Use o log bruto para preencher as seções novas.

## Template

```markdown
# 📓 Diário — DD/MM/AAAA (dia da semana) · Dia N de 6
> **Fase:** … · **Progresso:** A% → B% · **Commits:** `hash` `hash`

## Em 3 linhas
Resumo do dia para reler em 10 segundos.

## ⏱️ Linha do tempo
| Hora | O que aconteceu | Quem conduziu |
|---|---|---|

## 🧭 Decisões
| Decisão | Opções consideradas | Escolha e argumento da Camila | Fonte |
|---|---|---|---|

## ❓ O que eu questionei
- Pergunta da Camila → o que descobrimos

## 🧠 O que aprendi
- **Conceito:** explicação curta → _(Camila: reescreva com suas palavras)_

## 🤝 Divisão do trabalho
- **Eu fiz:** …
- **Claude fez (com minha aprovação):** …

## 🔧 Recursos do Claude usados
| Recurso | Para quê |
|---|---|

## ✅ Como verifiquei
- …

## 🐞 O que deu errado
| Problema | Causa | Correção | Aprendizado |
|---|---|---|---|

## 💡 Ideias estacionadas
- … (→ IDEIAS.md)

## ✍️ Espaço da Camila (só eu escrevo aqui)
- Como me senti hoje:
- O que eu faria diferente:
- Uma frase que quero usar no README:

## ➡️ Amanhã começa por
- …
```
