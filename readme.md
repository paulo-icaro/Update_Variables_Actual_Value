# Atualização de Valores Monetários
Paulo Icaro
2026-11-24

<!------------->

<!-- PARTE 1 -->

<!------------->

## Objetivo

<p>

      Este repositório
[Update_Variables_Actual_Value](https://github.com/paulo-icaro/Update_Variables_Actual_Value)
foi criado no intuito de auxiliar a conversão de valores monetários.

<!------------->

<!-- PARTE 2 -->

<!------------->

## Função **value_update**

<!------------------------------------------->

<!--- Detalhamento Função Github Document --->

<!------------------------------------------->

``` r
value_update(series, variables, base_period, start, end, show_price_index, extract_load_price_index)
```

<!------------------------------->

<!--- Detalhamento Função PDF --->

<!------------------------------->

<!-------------------------------->

<!--- Detalhamento Função HTML --->

<!-------------------------------->

<p>

       A função
[value_update](https://github.com/paulo-icaro/Update_Variables_Actual_Value/blob/main/update_actual_value.R)
é responsável pela correção monetária. A função necessita da
especificação dos seguintes argumentos para realizar a conversão:

</p>

| **Argumento** | **Descrição** | **Observação** |
|:---|:---|:---|
| series | Conjunto de dados que passará pelo processo | (Obrigatório) |
| variables | Nome das colunas que serão atualizadas | (Obrigatório) |
| base_period | Período ao qual se deseja realizar a conversão | Caso não seja informado, será considerado o período mais recente do IPCA. (Opcional) |
| start | Período de inicial ao qual a série do IPCA será extraída | Defina de modo que a série de IPCA seja compatível em termos de frequência temporal com as variáveis a serem atualizadas. (Obrigatório) |
| end | Período final ao qual a série IPCA será extraída | Caso não seja informado, será considerado extraído a série até o dado mais recente disponível. (Opcional) |
| price_index_code | Código da série de preços a ser utilizada na atualização | Caso não seja informado, será considerado o índice IPCA. (Opcional) |
| price_index_name | Nome da série de preços a ser utilizada na atualização | Caso não seja informado, será considerado o índice IPCA. (Opcional) |
| show_price_index | Define se o usuário deseja que as séries utilizadas para corrigir os valores seja adicionada ao conjunto de dados. | Caso não seja informado, será adicionado a série do Índice IPCA e a também a versão da série transformada na base informada pelo usuário |
| extract_load_price_index | Opção disponível para importar o índice de preços de um arquivo local | (Opcional) |

<p>

      O procedimento de correção monetária tem como base o Índice de
Preços ao Consumidor Amplo (IPCA) extraído diretamente da
[API](https://www.ipeadata.gov.br/Default.aspx)[^1] do Instituto Ipea.
Caso deseje realizar a correção utilizando outro índice, o usuário tem a
opção de selecionar outro índice que esteja disponível na API utilizando
os argumentos `price_index_code` e `price_index_name`. Em último caso,
se desejar importar a série de preços de um arquivo do tipo **.xlsx**,
basta usar o argumento `extract_load_price_index`.\
      Através do argumento `base_period` o usuário tem a liberadade para
determinar[^2] o período ao qual deseja fazer a conversão. O último
período disponível será considerado[^3] no caso da variável não ser
especificada. O usuário precisa indicar o período selecionado utilizando
o seguinte padrão de data: `AAAA-MM`.\
      Durante o processamento das informações, além da série de preços
no ano base vindo da API, uma nova coluna da série de preços ajustada ao
período base selecionado é adicionada a base de dados inicial. Caso o
usuário não deseje que essas duas componham a base final, deve ajustar o
argumento `show_price_index`.

</p>

<!------------->

<!-- PARTE 3 -->

<!------------->

## Aplicação: Atualização das séries de Exportação e Importação do Brasil

<p>

      Vejamos a seguinte aplicação: serão extraídas[^4] as séries de
exportação e importação para o Brasil a valores nominais, considerando o
intervalo 2015-2025, as quais serão devidamente corrigidas a valores de
dezembro de 2025.

</p>

``` r
# =============== #
# === Scripts === #
# =============== #
source('https://raw.githubusercontent.com/paulo-icaro/Bacen_API/main/bacen_query.R')


# ======================= #
# === Data Extraction === #
# ======================= #

# --- Informações Prévias --- #
cod_bacen_series = c('13093', '13094')
name_bacen_series = c('exportacao', 'importacao')
start_date = '01/01/2015'
end_date = '31/12/2025'

# --- Extração --- #
dataset = bacen_query(cod_bacen_series, name_bacen_series, start_date, end_date)

# --- Ajuste na Data --- #
dataset = dataset %>% mutate(data = as.Date(data, tryFormats = c('%d/%m/%Y')))

# --- Ajuste para tipo numérico
dataset[c(-1)] = lapply(X = dataset[c(-1)], FUN = as.numeric)
```

              data exportacao importacao
    123 2025-03-01     122183     226508
    124 2025-04-01     151710     248738
    125 2025-05-01     269730     224740
    126 2025-06-01     301550     201740
    127 2025-07-01     282922     227182
    128 2025-08-01     152131     205312
    129 2025-09-01     159111     223306
    130 2025-10-01     216222     202642
    131 2025-11-01     191004     196541
    132 2025-12-01     211301     184829

``` r
# =============== #
# === Scripts === #
# =============== #
source('https://raw.githubusercontent.com/paulo-icaro/Update_Variables_Actual_Value/refs/heads/main/update_actual_value.R')


# ========================== #
# === Correção Monetária === #
# ========================== #
dataset_adjusted = value_update(series = dataset, variables = c('exportacao', 'importacao'), base_period = '2025-12', show_price_index = TRUE, start = 2015)
```

              data    ipca  ipca_adj exportacao importacao
    123 2025-03-01 7245.38  97.86703   124845.9   231444.6
    124 2025-04-01 7276.54  98.28792   154352.6   253070.8
    125 2025-05-01 7295.46  98.54349   273716.7   228061.8
    126 2025-06-01 7312.97  98.78000   305274.3   204231.6
    127 2025-07-01 7331.98  99.03678   285673.7   229391.5
    128 2025-08-01 7323.91  98.92777   153779.9   207537.3
    129 2025-09-01 7359.06  99.40256   160067.3   224648.1
    130 2025-10-01 7365.68  99.49198   217326.1   203676.7
    131 2025-11-01 7378.94  99.67109   191634.3   197189.6
    132 2025-12-01 7403.29 100.00000   211301.0   184829.0

<p>

      Neste exercício,a série IPCA padrão e sua versão com a base
convertida para o período 2025-12 foram adicionadas as series
corrigidas. Note também que estruturalmente a função foi criada de modo
a transformar bases de dados onde cada variável/série está contida em
uma coluna de dados. Outros formatos do conjunto de dados tornam a
aplicação da função inviável.

</p>

[^1]: [Clique
    aqui](https://github.com/paulo-icaro/Ipeadata_API/blob/main/readme_pt_br.md)
    para mais detalhes a respeito da extração da série de inflação.

[^2]: É importante destacar que a escolha de um período factivel para
    evitar erro na execução da rotina.

[^3]: Por padrão o argumento recebe o status `most_recent` indicando que
    o período a ser considerado será o mais recente.

[^4]: A extração das séries foi possível por meio do uso da função
    [bacen_query](https://github.com/paulo-icaro/Bacen_API)
