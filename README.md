Documentação do Processo de Elaboração
O conjunto de dados foi extraído do Kaggle. O objetivo desta documentação é demonstrar o processo e os resultados obtidos.

Visão Geral
O processo ETL é composto por várias etapas, cada uma das quais é descrita abaixo:

Extração (Extract)
Nesta etapa, os dados foram extraídos do banco de dados do site do Kaggle e importados para o Microsoft SQL Server.

Transformação (Transform)
Nesta etapa, os dados extraídos são processados e transformados.

A primeira etapa foi alterar o nome das colunas para um padrão que facilitasse a manipulação dos dados. Assim, no item (01), os nomes das colunas foram alterados.

A segunda etapa (2.0) foi buscar inconsistências nos dados para limpeza e pré-processamento.

Em seguida, as colunas de carimbo de data/hora foram separadas em novas colunas de data e hora, e o horário AM/PM foi convertido para o formato de 24 horas.

No item (0.3), foram realizadas breves verificações para entender alguns dados faltantes e compreender os tipos de dados.

Continuando, foram convertidas as colunas que continham dados de média e eram do tipo string para o tipo float.

Carga (Load)
Por fim, os dados transformados são carregados de volta ao banco de dados, substituindo ou atualizando as informações existentes. Aqui, os dados estão prontos para serem consumidos no Tableau.
