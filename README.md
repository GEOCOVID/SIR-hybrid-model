# Covid Flux

# Modelo Geoespacial de Propagação do Coronavírus  

## Conteúdo

- [Programa MATLAB](#programa-matlab)
  - [Pré-requisitos](#pré-requisitos)
  - [Preparação](#preparação)
- [Modelo](#modelo)
  - [Objetivo do Modelo](#objetivo-do-modelo)
  - [Descrição dos Cenários](#descrição-dos-cenários)
  - [Explicação detalhada do Modelo](#explicação-detalhada-do-modelo)
- [Referências](#referências)
- [Créditos](#créditos)
- [Licença](#licença)

---

### Programa MATLAB

Esse repositório contém os códigos em `MATLAB` desenvolvidos por @vivasm :octocat:. O repositório está dividido em:
- [`data/`](data/) -> Dados de entrada para o modelo.
- [`src/`](src/) -> Códigos fonte em MATLAB.
- [`results/`](results/) -> Arquivos de saída, separados por estados/região.
- `RodaXX.m` -> São arquivos que executam todo o pipeline definindo as regiões/estados, parâmetros e arquivos de saída e entrada.

#### Pré-requisitos

- [MATLAB](https://www.mathworks.com/products/matlab.html)

#### Preparação

A fim de otimizar o processamento, a função [`runFlux`](src/runFlux.m) foi compilada para o formato [`mex`](https://en.wikipedia.org/wiki/MEX_file) do MATLAB. O programa invoca a função compilada `runFlux_mex`. Para gerar o arquivo dessa função, deve-se, pela interface do `MATLAB`, caminhar até o diretório `src` e executar o seguinte comando:

```
codegen runFlux.m
```

Caso o usuário não queira utilizar a versão compilada, basta renomear a invocação no arquivo [`Covid19.m`](https://github.com/vivasm/Covid_flux/blob/5ad356f5c62038478ba367a8fc73ce2d02c82242/src/Covid19.m#L116) de `runFlux_mex` para `runFlux`.

### Modelo

As informações referentes à dinâmica de contágio entre municípios apresentadas neste site são frutos de um modelo matemático epidemiológico do tipo SIR que estima, para cada município, a dinâmica populacional na propagação do contágio. Para cada dia de previsão do modelo, utilizamos a rede de fluxo entre municípios para estimar a propagação dos casos no estado. Os dados utilizados como condições iniciais do modelo (número de casos em cada município) são atuais e divulgados pelas secretarias de saúde. Os dados de fluxo entre municípios foram extraídos do censo Redes e Fluxos do Território publicado pelo IBGE<sup>1</sup> e referem-se a dados coletados em 2016.  Os dados de fluxo do IBGE não apresentam fluxo para duas cidades: Lauro de Freitas e Aurelino Leal. Para essas cidades os fluxos foram estimados a partir do fluxo local com as cidades de Salvador e Ubaitaba, respectivamente.

É importante enfatizar que os resultados do modelo representam apenas uma simplificação das características gerais do fenômeno, NÃO apresentando um caráter preditivo absoluto.  

Os parâmetros do Modelo **SIR** foram obtidos do Painel de monitoramento da rede COVIDA http://covid19br.org/.

#### Objetivo do Modelo

O objetivo do modelo é o de ilustrar a importância do isolamento social na contenção do contágio da doença.
Para tal utilizaremos dois cenários: com e sem supressão de fluxo.

#### Descrição dos Cenários

Desenvolvemos dois cenários para o presente modelo:

* **Cenário 1** - Sem supressão de Fluxo

  Neste cenário, a população mantém a circulação normal dentro das cidades e há uma pequena redução (30%) do fluxo de pessoas entre as cidades. Espera-se que vários municípios simultaneamente apresentem um aumento acelerado do número de pessoas infectadas. Além disso, o elevado número de pessoas infectadas pode provocar um colapso no sistema público de saúde e consequentemente uma alta taxa de mortalidade.

* **Cenário 2** - Com supressão de Fluxo

  Neste segundo cenário, a população entra em quarentena com redução de 50% da circulação dentro das cidades e uma redução de 80% na circulação entre as cidades. Espera-se haja uma redução no número de infectados e redução da quantidade de municípios afetados pela pandemia.  Há uma grande redução no pico de casos, de forma que menos pessoas ficarão sem o atendimento médico em casos de necessidade.

  Desta forma podemos perceber que a quarentena é de vital importância para mitigar o efeito do coronavírus sobre a população.

#### Explicação detalhada do Modelo

Trata-se de um modelo híbrido envolvendo a técnica de equações diferenciais ordinárias (EDO) e a técnica de difusão em rede. Para cada passo de tempo o modelo resolve múltiplas EDOs para cada município, considerando como condições iniciais a quantidade de casos e recuperados de cada município. Após isso a rede de fluxo é utilizada para distribuir as populações de suscetíveis, infectados e recuperados entre os pares de municípios e uma nova população é estimada para o próximo passo.
Utilizamos o modelo de EDO que atualmente melhor se ajusta aos dados, Modelo **SIR** descrito pelas seguintes equações diferenciais:

<p align="center">
<img src="https://latex.codecogs.com/svg.latex?%5C%5C%20%5Cfrac%7BdS%7D%7Bdt%7D%20%3D%20-%20%5Cbeta%20%5Ccdot%20S%20%5Ccdot%20I%20%5C%5C%20%5Cfrac%7BdI%7D%7Bdt%7D%20%3D%20%5Cbeta%20%5Ccdot%20S%20%5Ccdot%20I%20-%20%5Cgamma%20%5Ccdot%20I%20%5C%5C%20%5Cfrac%7BdR%7D%7Bdt%7D%20%3D%20%5Cgamma%20%5Ccdot%20I">
</p>

Onde **S** representa a população de suscetíveis à doença, **I** a população de infectados e **R** a de recuperados. **𝜷** e **𝜸** são taxas que representam a dinâmica de propagação da doença. Utilizamos os valores de **𝜷** e **𝜸** do estado estimados pelo Painel de monitoramento da rede COVIDA http://covid19br.org/.

É muito importante salientarmos que os resultados apresentados são aproximações e os seguintes limites devem ser considerados:

1. Estamos utilizando os valores das taxas dinâmicas, **𝜷** e **𝜸**, iguais para todos os municípios, tendo como base o valor do estado. Obviamente cada município terá sua própria dinâmica. Esperamos a evolução da coleta de dados para que possamos estimar as taxas de cada município e assim aprimorar o modelo.
2. Os dados de fluxo são referentes ao censo de transporte urbanos do IBGE de 2016 em condições normais de fluxo. Devido a restrições impostas pela epidemia pode ter havido alterações nas condições de fluxo, contudo acreditamos que o mecanismo geral de atraso entre a capital e o interior se mantenha.

---

### Referências

<sup>**1**</sup>: INSTITUTO BRASILEIRO DE GEOGRAFIA E ESTATÍSTICA (IBGE). Redes e fluxos do território: ligações rodoviárias e hidroviárias, 2016. Rio de Janeiro: 2017. Disponível em: https://www.ibge.gov.br/apps/ligacoes_rodoviarias/ Acesso em: 27 out. 2017.

### Créditos

- @vivasm  
    Desenvolvedor do Modelo

- @bertolinocastro  
    Estruturação e submissão ao GitHub.

### Licença

Licenciado sob a [ainda sem licença]()
