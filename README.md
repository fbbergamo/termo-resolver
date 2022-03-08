# Termo Resolver

Esse repo tem como objetivo criar uma forma para resolver o (term.ooo)[term.ooo], ajudar a processar, fazer análise das palavras e qual a melhor palavras com mais "informação" para começar o jogo.

## Estrategia

### Legenda

* Amarelo (A) -> (A palavra existe mas está no lugar errado)
* Preto (P)-> (A letra não existe, em caso de duplicatas pode ser que não tem uma segunda ocorrência na palavra, ex "errei" pode ter o primeiro r como verde e o segundo como preto indicando que não tem um segundo R.)
* Verde (V)-> A letra existe e está na posição correta

Na primeira fase o programa calcula qual a palavra inicial é a melhor para começar o jogo, usa algo descrito aqui https://www.youtube.com/watch?v=fRed0Xmc2Wg

Basicamente está listando todos os padrões que podem acontecer como:

```
[v, v, v, v, p]
...
[v, v, v, a, a]
...
[v, v, a, a, a]
```

Lista com 243 padrões.

Para cada palavra do jogo é calculado quantas palavras possíveis serão retornadas para cada padrão, ex:

```
possible_words("errei", ["a", "a", "p", "v", "p"]).size
```

No exemplo com "errei", é retornado 39 palavras, depois se calcula a probabilidade desse padrão ser retornado para o começo do jogo iremos ter 39/10588 -> 0,36% de chance

calculando a "informação" dessa palavra para esse caso temos:

```
inf = CMath.log2(1/0.003683415) * 0.003683415
0.029779453816910016
```

E somando todas as informações por todos os padrões possíveis, vamos ter um score para "errei".

Repetimos esse processo para todas as 10588 palavras, para ter uma lista com scores que rankeado será utilizado para a primeira palavra do jogo.

Neste programa a primeira palavra escolhida foi "arari" (ler disclaimer)

Para o final do jogo se usa uma rank de frequencia

# Setup
Instalar Ruby 2.7

irb
```
  load "main.rb"

  play_game("balao")
```

## Disclaimer
* Não tenho muita experiência com estatística.
* O código não está com testes.
* A lógica para tanto resolver o jogo quanto para listar as possíveis palavras está bem confusa.

## Inspiração e referências

* Dicionario de frequencia retirado de https://github.com/fserb/pt-br
* https://www.youtube.com/watch?v=v68zYyaEmEA
* https://www.youtube.com/watch?v=fRed0Xmc2Wg
* https://github.com/luxedo/botinho-do-termo
