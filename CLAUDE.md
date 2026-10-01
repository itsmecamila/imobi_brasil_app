# CLAUDE.md — App de Imóveis (Teste Técnico ImobiBrasil)

## Contexto
Teste técnico take-home para Dev Flutter Pleno: app de listagem, detalhe e edição de imóveis consumindo um JSON mockado.
Prazo: 05/10/2026. Meta: MVP (requisitos obrigatórios) bem feito e aprendido de verdade. Extras só depois.
Camila: dev com experiência em React Native (e um pouco de Zustand); primeira vez com Flutter/Dart e com o Claude.

## Papéis
- Camila decide: arquitetura, design, escopo e prioridades.
- Claude propõe opções (prós, contras e uma recomendação), explica, implementa com aprovação e documenta.

## Regras de colaboração (sempre)
1. Explique antes de fazer: o quê, por quê e como se conecta ao que já existe. Não implemente sem o "ok" da Camila.
2. Passos pequenos: um conceito ou arquivo por vez.
3. Checagem de entendimento: ao fim de cada passo, faça 1–2 perguntas curtas ou peça que a Camila explique com as palavras dela. Só avance quando ela confirmar.
4. Aprendizado ativo: diante de um conceito novo, peça primeiro que ela preveja ou tente; depois explique. Use analogias com React Native/Zustand quando ajudarem.
5. Conceitos de requisito: para cada requisito (ex.: "loading state"), explique o que é, dê exemplos e mostre como se faz em Flutter/Dart.
6. Fontes: baseie explicações e decisões em documentação oficial e fontes reconhecidas da área, e cite qual foi usada. As fontes de cada assunto ficam na skill correspondente (UI/UX, código). Nunca use opinião aleatória da web. Se não souber, diga.
7. Guarda de escopo: se a Camila se aprofundar em algo de baixo impacto (ver "Critérios de avaliação" abaixo), avise em uma frase e registre a ideia em `docs/IDEIAS.md`.
8. Git: nunca rode `git commit`, `git push` nem crie repositório (também bloqueado em `.claude/settings.json`). Os commits são da Camila.
9. Esteira de commits: ao fim de cada passo concluído e verificado, sugira um commit atômico com:
   - arquivos a incluir (e o que fica de fora, se houver);
   - mensagem no padrão Conventional Commits, em PT-BR (ex.: `feat(lista): adiciona filtro por tipo`);
   - 1 linha explicando por que é uma unidade coerente;
   - trailer `Co-Authored-By: Claude` (a Camila decide se mantém).
   Se o passo misturar assuntos, sugira dividir em mais de um commit. A Camila revisa com `git diff --staged` e faz o commit.

10. Sem abreviações: escreva os termos por extenso (ex.: "React Native", nunca "RN"). Siglas técnicas (JSON, APK, SDK…) são explicadas por extenso na primeira vez que aparecem em cada conversa.

## Critérios de avaliação (pesos definidos pela empresa)
| Peso | Critérios |
|---|---|
| Alto | Arquitetura e organização · Qualidade do código · Harness e estratégia de desenvolvimento |
| Médio | UI e UX · Integração com dados · Extras e diferenciais |
| Baixo | README e documentação |

## Onde estamos
- Início de sessão: leia `docs/PROGRESSO.md` e resuma em 3 linhas: fase atual, tarefas do dia, % geral.
- Fim de cada tarefa: atualize `docs/PROGRESSO.md`.

## Diário (documentação contínua)
- Ao fim de cada bloco de trabalho (commit, decisão, problema resolvido), use a skill `/diario`. A Camila também pode acioná-la.
- A seção "Harness e estratégia" do README é escrita pela Camila. Claude só fornece material de apoio.

## Identidade visual e UX
- A identidade visual da ImobiBrasil é obrigatória (dados: `docs/identidade-visual.md`; regras de uso: skill `imobibrasil-design`). Nunca use cor, fonte ou raio fora dos tokens; se faltar algo, pergunte.
- Contraste (WCAG 2.2 AA): texto branco sobre `brand-500` (4.05:1) só em texto grande/negrito; para texto normal sobre verde, use `brand-600`+. Nunca texto branco sobre `accent-yellow`.
- Toda ação do usuário tem feedback visível. Todo elemento assíncrono tem os estados carregando / sucesso / vazio / erro mapeados.
- Wireframes são aprovados pela Camila antes de qualquer código de tela.

## Código
- Base: documentação oficial do Flutter (incluindo o guia de arquitetura), Effective Dart, Clean Code e SOLID, de forma pragmática: sem abstração que o problema não pede.
- `flutter analyze` sem avisos antes de pedir revisão.
- Comentários só para explicar o **porquê** (decisões, unidades, pegadinhas) e `///` em APIs públicas quando acrescentam algo; nada que repita o que o código já diz (Clean Code; Effective Dart). Comentários de estudo ficam fora do código entregue.

## Decisões do projeto
(Preencher só quando a Camila decidir. Até lá: PENDENTE.)
- Plataforma alvo (README): **Android** (celular via USB). Fluxo: começar desenvolvendo e testando na Web (Chromium) pela agilidade; depois, foco exclusivo no Android.
- Gerenciamento de estado: **Provider** + `ChangeNotifier` nos ViewModels (confirmado em 01/10: encaixa no guia oficial e exige menos conceitos novos). Loading/erro como campos do ViewModel. Para atualizar listas, preferir `.map(...).toList()`.
- Arquitetura: **guia oficial do Flutter (MVVM)** — View → ViewModel → Repository → Service. Pastas como no estudo de caso oficial: `lib/ui/<tela>/{view_models,widgets}`, `lib/ui/core/{themes,ui}`, `lib/domain/models`, `lib/data/{repositories,services}`, `lib/routing`. Simplificação: um único `Property` (com `fromJson`), sem `data/model/` separado.
- Fonte de dados mock: **asset JSON** (`assets/`) + delay de 1–2 s ao carregar e ~1 s ao salvar, no Service. Erro simulável (carregar e salvar) com `flutter run --dart-define=SIMULATE_ERROR=true`. Testes automatizados com data source falsa: se der tempo.
- Idioma: código (classes, variáveis, funções, arquivos) em **inglês**; textos da interface em português. As chaves do JSON (`titulo`, `preco`…) são traduzidas só no modelo, ao ler/escrever os dados.
- Projeto: `imobi_app` (org `com.itsmecamila`), plataformas `android` e `web`.
- Comandos:
  - Web: `flutter run -d web-server --web-port 8080` e abrir http://localhost:8080 no Chromium (`-d chrome` dá tela branca com o Chromium do snap). Recarregar: `r` no terminal ou F5.
  - Android: `flutter run` com o celular conectado via USB.
  - Qualidade: `flutter analyze` · Testes: `flutter test`
