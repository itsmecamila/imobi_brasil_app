# Matriz de estados

Todo elemento que depende de algo assíncrono (dados, imagens, ações externas) tem os estados definidos abaixo. Base: skill `ux-imobi` (pilares "o app conversa" e "prevenir e recuperar").

## Tela 1 — Lista

| Elemento | Carregando | Sucesso | Vazio | Erro |
|---|---|---|---|---|
| Lista de imóveis | Indicador circular + "Carregando imóveis…" | Cards | **Sem resultado na busca/filtro:** "Nenhum imóvel encontrado para 'xyz'. Tente outro termo ou mude o filtro." · **Sem imóveis cadastrados:** "Nenhum imóvel cadastrado ainda." | "Não foi possível carregar os imóveis agora." + botão **Atualizar** |
| Foto do card | Área cinza (`border`) com ícone de imagem | Foto | — | Área cinza com ícone de casa + "Foto indisponível" |
| Busca e filtro | — (filtragem local e instantânea) | Lista filtrada | ver "Vazio" acima | — |

## Tela 2 — Detalhe

| Elemento | Carregando | Sucesso | Vazio | Erro |
|---|---|---|---|---|
| Dados do imóvel (ex.: aberto direto pela URL na Web) | Indicador circular | Detalhe completo | — | **Não encontrado:** "Este imóvel não está mais disponível." + botão **Voltar para a lista** |
| Foto | Área cinza com ícone de imagem | Foto | — | Área cinza com ícone de casa + "Foto indisponível" |
| Contato (WhatsApp, Ligar, E-mail) | — | Abre o app externo | — | "Não foi possível abrir o WhatsApp. Tente ligar ou enviar um e-mail." (mensagem adaptada ao canal) |

## Tela 3 — Edição

| Elemento | Carregando | Sucesso | Vazio | Erro |
|---|---|---|---|---|
| Campo do formulário | — | Normal (sem destaque verde) | — | Borda e ⚠ em `danger` + mensagem em `text-2` abaixo do campo, ao sair do campo e ao tocar em Salvar |
| Tocar em Salvar com campos inválidos | — | — | — | Foco no 1º campo errado + SnackBar "Corrija o campo destacado para salvar." / "Corrija os N campos destacados para salvar." (botão nunca desativado) |
| Salvar | Botão "Salvando…" desabilitado, com indicador, ~1 s | Volta ao detalhe atualizado + SnackBar "Imóvel atualizado" | — | Permanece na edição, mantém o que foi digitado + SnackBar "Não foi possível salvar agora." com ação **Atualizar** |

## Splash

Exibida por ~2 s com o logo; sem estados de erro (não depende de dados).
