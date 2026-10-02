---
name: ux-imobi
description: Princípios de UX/UI do app de imóveis, escritos pela Camila — pilares, regras de usabilidade, componentes Material 3 e acessibilidade. Use antes de qualquer trabalho de interface — wireframes, telas, componentes, estados (carregando/vazio/erro/sucesso), mensagens e formulários.
---

# UX do app de imóveis

Essa skill existe para padronizar boas práticas de experiência do usuário na aplicação. Valorizo essa parte pois acredito que ela é a primeira responsável por construir relação com o usuário/cliente, e quando bem planejada e executada, causa ótimas impressões visuais e de usabilidade, as quais em muitos casos de uso podem ajudar a amenizar o impacto de problemas funcionais, funcionando como uma aliada, trazendo a transparência adequada e proporcionando a consciência do usuário de que não tem nada de errado com ele, por exemplo, e sim com algo interno que pode já estar sendo resolvido. Meu objetivo é que a aplicação seja apenas uma facilitadora de acesso a informações, da forma mais satisfatória possível, e que os recursos humanos sejam focados nas partes decisórias e de negociação, onde um contato mais próximo é essencial. 

A identidade visual (cores, fonte, raios, contraste dos tokens) está em `docs/identidade-visual.md` e também é obrigatória.

## Os 3 pilares

### 🗣️ O app conversa
_Heurísticas de Nielsen: 1 (visibilidade do status do sistema) e 10 (ajuda e documentação)._

"O usuário e o aplicativo constroem uma relação recíproca, onde jamais o usuário se sente perdido ou confuso sobre como fazer uma ação, sobre o que está acontecendo. Existe clareza e facilidade de usabilidade, acessível para qualquer usuário, do mais leigo ao mais experiente." — Camila

**Regras:**
1. Toda ação assíncrona mostra progresso enquanto acontece (indicador ao carregar a lista; botão "Salvando…" desabilitado ao salvar). _(H1)_
2. Toda ação concluída tem confirmação breve e visível (ex.: SnackBar "Imóvel atualizado"). _(H1)_
3. Todo toque tem resposta visual imediata; não remover o efeito de toque padrão do Material. _(H1)_
4. Textos na língua do usuário: "Aluguel", "R$ 1.800,00 /mês" (aluguel leva "/mês"; venda não), "65 m²", "Sem quartos", "1 vaga" (singular/plural); nunca valores crus (`1800.0`) ou termos técnicos. _(H2)_
5. Estado vazio explica o motivo e o que fazer (ex.: "Nenhum imóvel encontrado para 'xyz'. Tente outro termo ou mude o filtro."). _(H10)_
6. Ícones sem texto têm rótulo (tooltip e leitor de tela), ex.: "Editar imóvel". _(H10 + acessibilidade)_

### 🛡️ Prevenir e recuperar
_Heurísticas de Nielsen: 5 (prevenção de erros) e 9 (ajudar a reconhecer, diagnosticar e recuperar-se de erros)._

"Transparência e possibilidade de correção de caminhos por engano ajudam o usuário a se autocorrigir." — Camila

**Regras:**
1. Restringir em vez de corrigir depois: tipo como lista de opções; teclado numérico em preço, área e contagens. _(H5)_
2. A mensagem de erro aparece junto ao campo com problema, não só no topo da tela. _(H9)_
3. Toda mensagem de erro diz o que aconteceu e como resolver, em linguagem simples e sem códigos (ex.: "Informe um preço maior que zero."). _(H9)_
4. Erro de carregamento ou de salvamento sempre oferece uma ação de recuperação, com o rótulo "Atualizar". _(H9)_
5. Nunca culpar o usuário; quando o problema é interno, dizer isso (ex.: "Não foi possível carregar os imóveis agora."). _(H9)_
6. Nunca apagar o que o usuário digitou por causa de um erro; o formulário mantém os valores para correção. _(H5)_
7. Formulários em uma coluna, um campo por linha, para cada mensagem de erro ficar logo abaixo do seu campo. Exceção: campos curtos que nunca exibem erro (quartos, banheiros, vagas) podem ficar lado a lado. Mensagens curtas que dizem como resolver ("Informe o título."); se precisarem de duas linhas, quebram sem cortar. _(H9 + NN/g, formulários)_
8. Botão de envio nunca fica desativado por formulário inválido: ao tocar com erros, levar o foco ao 1º campo errado **e** avisar quantos campos corrigir (SnackBar, anunciada pelo leitor de tela). _(H1 + H9; Friedman, "Disabled Buttons", Smashing Magazine, 2021)_

### 🧭 O usuário no controle
_Heurísticas de Nielsen: 3 (controle e liberdade do usuário) e 6 (reconhecer em vez de lembrar)._

"Navegação sempre intuitiva." — Camila

**Regras:**
1. Sempre há um caminho de volta visível (seta na barra do detalhe e da edição); o botão voltar do Android se comporta igual. _(H3)_
2. Cancelar na edição descarta tudo e volta ao detalhe, sem etapas extras (intenção explícita). Já a seta ← ou o voltar do Android **com mudanças não salvas** pedem confirmação: "Descartar alterações?" · Editar · Descartar (toque acidental; H5). Sem mudanças, voltam direto. _(H3 + H5)_
3. Busca e filtro ativos ficam visíveis ou reaparecem com um leve gesto para cima (quick return): segmento selecionado destacado, texto no campo, botão ✕ para limpar a busca. _(H6)_
4. Ao voltar do detalhe para a lista, busca, filtro e posição da rolagem continuam como estavam. _(H6)_
5. A edição abre preenchida com os valores atuais. _(H6)_
6. Os nomes dos campos ficam sempre visíveis, acima da caixa (não o rótulo flutuante do Material), sem depender de placeholder que some ao digitar. _(H6 + NN/g, formulários)_

## Componentes (Material 3)
- Usar os componentes padrão do Material 3 (consistência, heurística 4), com as cores da marca aplicadas pelo tema; nunca estilizar componente a componente.
- **Hierarquia de botões:** `FilledButton` para **a** ação principal da tela (no máximo um por tela) › `OutlinedButton` para ação secundária importante › `TextButton` para ações de baixo peso (ex.: Cancelar).
- **Seleção:** poucas opções (2–5), fixas e mutuamente exclusivas → `SegmentedButton`. Muitas opções, dinâmicas ou combináveis → chips (`FilterChip`/`ChoiceChip`).
- **Mapeamento do app:**
  | Elemento | Componente |
  |---|---|
  | Barra superior | `AppBar` |
  | Busca | `TextField` (ou `SearchBar`) |
  | Filtro Todos/Venda/Aluguel | `SegmentedButton` |
  | Card do imóvel | `Card` (foto em cima) |
| Características no detalhe | grade 2×2 (ícone + texto) |
  | Carregando | `CircularProgressIndicator` |
  | Editar | `IconButton` (lápis) com rótulo de acessibilidade |
  | Entrar em Contato | `FilledButton` → conteúdo único; tela estreita (< 600): painel de baixo (`showModalBottomSheet`); tela larga: `AlertDialog` |
  | Campos do formulário | `TextField` com mensagem de erro abaixo; teclado numérico em preço, área e contagens |
  | Tipo (venda/aluguel) | `DropdownMenu` |
  | Confirmação ao salvar | `SnackBar` |

## Acessibilidade
1. **Contraste:** mínimo 4.5:1 entre texto e fundo (ver tabela em `docs/identidade-visual.md`).
2. **Toque:** áreas tocáveis com pelo menos 48×48; não encolher os componentes do Material.
3. **Leitor de tela (TalkBack):** todo controle descrito em voz; ícones sem texto e imagens recebem rótulo (`Semantics`, `tooltip`, `semanticLabel`).
4. **Fonte grande:** a interface continua legível e usável com o texto do sistema ampliado; evitar alturas fixas em textos.
5. Ações importantes podem ser desfeitas; campos com erro sugerem a correção; nada muda de contexto automaticamente enquanto o usuário digita.

## Estados obrigatórios
Todo elemento que depende de dados assíncronos tem os quatro estados desenhados: **carregando · sucesso · vazio · erro** (erro sempre com uma ação de recuperação: "Atualizar").

## Fontes
- Nielsen Norman Group, *Website Forms Usability: Top 10 Recommendations* — https://www.nngroup.com/articles/web-form-design/
- Vitaly Friedman (2021), *Frustrating Design Patterns: Disabled Buttons* — https://www.smashingmagazine.com/2021/08/frustrating-design-patterns-disabled-buttons/
- Jakob Nielsen (1994), *10 Usability Heuristics for User Interface Design* — https://www.nngroup.com/articles/ten-usability-heuristics/
- Catálogo de componentes Material do Flutter — https://docs.flutter.dev/ui/widgets/material
- Guia de acessibilidade do Flutter — https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
- WCAG 2.2 (contraste) — https://www.w3.org/TR/WCAG22/
- Diretrizes do Material 3 — https://m3.material.io
