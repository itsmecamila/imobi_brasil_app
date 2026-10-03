---
name: imobibrasil-design
description: Regras de uso da identidade visual da ImobiBrasil no app — qual token de cor vai em cada elemento, decisões de contraste, tipografia Inter, raios e logos. Use antes de escrever ou revisar qualquer tema, tela, widget ou wireframe.
---

# Identidade visual ImobiBrasil — regras de uso

**Dados** (paleta, tipografia, raios, logos e tabela de contraste): `docs/identidade-visual.md`. Esta skill não repete os valores; define **como usá-los**.

## Regra de ouro
- Cores, fontes e raios vêm **só do tema**, definido em `lib/ui/core/themes/`. É o único lugar do código onde aparecem valores hexadecimais.
- Telas e widgets usam o tema (`Theme.of(context)`, `ColorScheme`, constantes do tema); nunca `Color(0x…)` direto.
- Nenhuma cor fora dos tokens. Se faltar uma cor, perguntar à Camila.

## Decisões de contraste (Camila, 01/10/2026)
1. **Verde com texto em cima → `brand-600`** (5.48:1). O `brand-500` (4.05:1) não passa em texto normal, nem com texto branco nem escuro; fica para ícones, bordas, indicadores e texto grande.
2. **Erro:** borda do campo e ícone ⚠ em `danger`; **o texto da mensagem em `text-2`**. O `danger` (4.22:1) não passa em texto normal e a paleta não tem vermelho mais escuro. Cor nunca é o único indicador: erro = cor + ícone + texto.
3. `accent-blue` e `accent-yellow` nunca levam texto branco; badge amarelo usa texto `text`.

## Mapa token → elemento
| Elemento | Token |
|---|---|
| Fundo da página | `bg` |
| Cards, diálogos, campos | `surface`, borda `border` |
| Texto principal / secundário / auxiliar | `text` / `text-2` / `muted` |
| `FilledButton` (ação principal) | fundo `brand-600`, pressionado `brand-700`, texto branco |
| `OutlinedButton` / `TextButton` | texto e contorno `brand-600` |
| AppBar | fundo `brand-600`, texto e ícones brancos, em todas as telas; na Lista, ícone da marca num quadro `surface` |
| Splash screen | fundo `surface`, logo completo centralizado |
| Foto em tela cheia | fundo `text` (o token mais escuro; preto puro não existe na paleta), ícone ✕ branco sobre branco translúcido |
| Status bar (Android) | `brand-800` |
| Ícones de ação, indicador de progresso, foco | `brand-500` |
| Links em verde | `brand-600` |
| Seleção (segmento ativo, item selecionado) | fundo `brand-50`, texto e ícone `brand-700` |
| Badge de destaque (ex.: tipo do imóvel) | fundo `accent-yellow`, texto `text` |
| Informação / ação secundária (ícones) | `accent-blue` |
| Erro / ação destrutiva | `danger` em bordas e ícones; mensagem em `text-2`. Botão destrutivo (ex.: "Descartar"): `OutlinedButton` com contorno e ícone `danger`, texto `text` |
| Desabilitado | `muted` |

## Tipografia e formas
- Fonte **Inter**, embutida no app (arquivos em `assets/`), sem download em tempo de execução: quebra testes e o modo offline.
- Raio **8** em botões e campos; **16** em cards.

## Logos
- Baixar os SVGs (logo completo e ícone) para `assets/` e exibir com `flutter_svg`; carregar da URL falha na Web (CORS).
- **Logo completo na splash screen; na AppBar da Lista, só o ícone num quadro branco** (Camila, 01/10/2026; ícone acrescentado na revisão da alta fidelidade): o logo original é verde (`#009035`) com detalhes amarelo e branco; sobre a AppBar verde ele some, e recolorir o logo alteraria um ativo da marca. O enunciado prevê o logo "para splash screen ou AppBar". A AppBar é verde em todas as telas, com título em texto branco. Na Lista, o ícone original (sem recolorir) fica num quadro `surface` de raio 8, à esquerda de "Imóveis".
