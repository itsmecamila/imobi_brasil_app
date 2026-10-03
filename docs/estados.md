# Matriz de estados

Todo elemento que depende de algo assíncrono (dados, imagens, ações externas) tem os estados definidos abaixo. Base: skill `ux-imobi` (pilares "o app conversa" e "prevenir e recuperar").

## Tela 1 — Lista

| Elemento | Carregando | Sucesso | Vazio | Erro |
|---|---|---|---|---|
| Lista de imóveis | Indicador circular + "Carregando imóveis…" | Cards | **Sem resultado na busca/filtro:** "Nenhum imóvel encontrado para 'xyz'. Tente outro termo ou mude o filtro." · **Sem imóveis cadastrados:** "Nenhum imóvel cadastrado ainda." | "Não foi possível carregar os imóveis agora." + botão **Atualizar** |
| Foto do card | Área cinza (`border`) com ícone de imagem | Foto | — | Área cinza com ícone de casa + "Foto indisponível" |
| Busca e filtro | — (filtragem local e instantânea) | Lista filtrada | ver "Vazio" acima | — |
| Botão "＋ Adicionar imóvel" | Oculto | Visível (também com a lista vazia) | — | Oculto (o novo id depende dos imóveis carregados) |

## Tela 2 — Detalhe

| Elemento | Carregando | Sucesso | Vazio | Erro |
|---|---|---|---|---|
| Dados do imóvel (ex.: aberto direto pela URL na Web) | Indicador circular | Detalhe completo | — | **Não encontrado:** "Este imóvel não está mais disponível." + botão **Voltar para a lista** |
| Foto | Área cinza com ícone de imagem | Foto | — | Área cinza com ícone de casa + "Foto indisponível" (o conteúdo encolhe para caber em espaços pequenos) |
| Foto em tela cheia (`/property/:id/photo`) | Área cinza com ícone de imagem (por link direto: "Carregando foto…") | Foto com zoom de 1× a 4× sobre fundo escuro | — | Área cinza com "Foto indisponível"; imóvel inexistente: "Este imóvel não está mais disponível." + Voltar para a lista |
| Contato (WhatsApp, Ligar, E-mail) | — | Abre o app externo | — | "Não foi possível abrir o WhatsApp. Tente ligar ou enviar um e-mail." (mensagem adaptada ao canal) |

## Tela 3 — Edição

| Elemento | Carregando | Sucesso | Vazio | Erro |
|---|---|---|---|---|
| Campo do formulário | — | Normal (sem destaque verde). A unidade da área fica no rótulo: "Área (m²)" | — | Borda e ⚠ em `danger` + mensagem em `text-2` abaixo do campo, ao sair do campo e ao tocar em Salvar |
| Tocar em Salvar com campos inválidos | — | — | — | Foco no 1º campo errado + SnackBar "Corrija o campo destacado para salvar." / "Corrija os N campos destacados para salvar." (botão nunca desativado) |
| Salvar | Botão "Salvando…" desabilitado, com indicador, ~1 s | Volta ao detalhe atualizado + SnackBar "Imóvel atualizado" | — | Permanece na edição, mantém o que foi digitado + SnackBar "Não foi possível salvar agora." com ação **Atualizar** |

## Tela 4 — Cadastro (extra)

Mesmo formulário da Edição (mesmos campos, regras e mensagens); só o que muda está abaixo.

| Elemento | Carregando | Sucesso | Vazio | Erro |
|---|---|---|---|---|
| Tela (ex.: aberta direto pela URL na Web) | Indicador circular + "Carregando…" até os imóveis chegarem | Formulário em branco | — | — |
| Tipo | — | "Venda" ou "Aluguel" | "Selecione…" (sem escolha inicial) | "Escolha venda ou aluguel." no padrão de erro dos campos |
| Quartos, banheiros, vagas | — | Número digitado | Vazio vale 0 | — |
| Cadastrar | Botão "Cadastrando…" desabilitado, com indicador, ~1 s | Volta à Lista com o novo no topo + SnackBar "Imóvel cadastrado" (ou "… Busca e filtro limpos para mostrá-lo.") | — | Permanece no cadastro, mantém o que foi digitado + SnackBar "Não foi possível cadastrar agora." com ação **Atualizar** |

A foto do imóvel novo é provisória (não há envio de foto): `picsum.photos` com o id na semente, mesmo serviço do JSON.

## Splash

Exibida por ~2 s com o logo; sem estados de erro (não depende de dados).
