# Identidade visual — ImobiBrasil

Fonte única de verdade para cores, tipografia e formas do app. Valores fornecidos pela empresa no enunciado do teste.

## Logotipos
- Logotipo completo (splash ou AppBar): https://imobibrasil.com.br/imagens/logotipo/svg/logo-original-imobibrasil.svg
- Ícone (favicon, ícone do app, elementos pequenos): https://imobibrasil.com.br/imagens/logotipo/svg/icone-original-imobibrasil.svg

## Paleta (tokens do Design System ImobiBrasil)
| Uso | Token | Hex |
|---|---|---|
| Primária (botões, AppBar, links, ícones) | `brand-500` | `#00923F` |
| Hover / pressionado | `brand-600` / `brand-700` | `#007A35` / `#00622B` |
| Primária escura (status bar, cabeçalhos) | `brand-800` | `#004A21` |
| Fundo sutil (chips, seleção, hover) | `brand-50` | `#E6F7ED` |
| Informação / ações secundárias | `accent-blue` | `#3B82C4` |
| Destaque (badges) | `accent-yellow` | `#F4C332` |
| Erro / ação destrutiva | `danger` | `#DC4545` |
| Fundo da página | `bg` | `#F7FAF8` |
| Cards, modais, containers | `surface` | `#FFFFFF` |
| Bordas | `border` | `#E3EEE7` |
| Texto principal | `text` | `#0F172A` |
| Texto secundário | `text-2` | `#334155` |
| Texto auxiliar / desabilitado | `muted` | `#64748B` |

## Tipografia e formas
- Fonte: **Inter**
- Raio de borda: **8px** em botões e inputs, **16px** em cards

## Contraste (WCAG 2.2, calculado em 30/09/2026)
Mínimo AA: 4.5:1 para texto normal; 3:1 para texto grande (≥ 18pt, ou ≥ 14pt em negrito) e componentes de interface.

| Combinação | Contraste | Uso permitido |
|---|---|---|
| branco sobre `brand-500` | 4.05 | só texto grande/negrito e ícones |
| branco sobre `brand-600` | 5.48 | texto normal ✅ |
| branco sobre `brand-800` | 10.49 | texto normal ✅ |
| branco sobre `accent-blue` | 4.06 | só texto grande/negrito |
| branco sobre `danger` | 4.22 | só texto grande/negrito |
| branco sobre `accent-yellow` | 1.65 | ❌ nunca |
| `text` sobre `accent-yellow` | 10.80 | texto normal ✅ (use este nos badges) |
| `brand-500` sobre `brand-50` | 3.64 | só texto grande/negrito e ícones |
| `muted` sobre `bg` | 4.53 | texto normal ✅ (no limite) |
| `muted` sobre `surface` | 4.76 | texto normal ✅ |
| `border` sobre `surface` | 1.19 | decorativo apenas; não usar como único indicador de estado |
| `text` sobre `brand-500` | 4.41 | só texto grande/negrito |
| branco sobre `brand-700` | 7.55 | texto normal ✅ |
| `brand-700` sobre `brand-50` | 6.79 | texto normal ✅ |
| `brand-800` sobre `brand-50` | 9.44 | texto normal ✅ |
| `brand-500` sobre `surface` | 4.05 | ícones e texto grande; não usar em texto normal |
| `brand-600` sobre `surface` | 5.48 | texto normal ✅ (links em verde) |
| `accent-blue` sobre `surface` | 4.06 | ícones e texto grande |
| `danger` sobre `surface` | 4.22 | bordas e ícones; não usar em texto normal |
| `danger` sobre `bg` | 4.01 | bordas e ícones |
| `text-2` sobre `surface` | 10.35 | texto normal ✅ |

_Pares adicionais calculados em 01/10/2026._
