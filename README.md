# Termo Resolver

Esse repo tem como objetivo criar uma forma para resolver o (term.ooo)[term.ooo], ajudar a processar, fazer analise das palavras e qual a melhor palavras com mais "informação" para começar o jogo.

## Estrategia

### Legenda

Amarelo (A) -> (A palavra existe mas está no lugar errado)
Preto (P)-> (A letra não existe, em caso de duplicatas pode ser que não tem uma segunda ocorrencia na palavra, ex "errei" pode ter o primeiro r como verde e o segundo como preto indicando que não tem um segundo R.)
Verde (V)-> A letra existe e está na posição correta

Na primeira fase o programa calcula qual a palavra inicial é a melhor para começar o jogo, usa algo descrito aqui https://www.youtube.com/watch?v=fRed0Xmc2Wg

Basicamente estou listando todos os padrões que podem acontencer como:

```
[v, v, v, v, p]
...
[v, v, v, a, a]
...
[v, v, a, a, a]
```

Lista com 243 padrões
E para cada palavra do jogo é calculado quantas palavras possiveis serão retornadas para cada padrão, depois é calculada a probabilidade desse padrão ser retornado, ex:

```
possible_words("errei", ["a", "a", "p", "v", "p"]).size
```

Retorna 39 palavras, calculado a probabilidade desse padrão ser retornado para o começo de jogo com "errei" iremos ter 39/10588  -> 0,36% de chance

calculando a "informação" dessa palavra para esse caso temos:

```
inf = CMath.log2(1/0.003683415) * 0.003683415
0.029779453816910016
```

E somando todas as informações por todos os padrões possiveis, vamos ter uma lista com valor que rankeado sera utilizado para a primeira palavra do jogo.

Neste programa a primeira palavra escolhida foi "arari" (ler disclaimer)

# Setup
Instalar Ruby 2.7

irb
```
  load "main.rb"

  play_game("balao")
```

## Disclaimer
Não tenho muita experiência com estatística.
O código não está com testes.
A logica para tanto resolver o jogo quanto para listar as possiveis palavras está bem confusa.

## Inspirado e referencias
Dicionario de frequencia retirado de https://github.com/fserb/pt-br
https://www.youtube.com/watch?v=v68zYyaEmEA
https://www.youtube.com/watch?v=fRed0Xmc2Wg
https://github.com/luxedo/botinho-do-termo
