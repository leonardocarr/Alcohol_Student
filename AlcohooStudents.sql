use AlcoholOnStudents

SELECT TOP (1000)*
  FROM [AlcoholOnStudents].[dbo].[Stats survey]


-- 0.1 Renomeando as Colunas para facilitar as próximas etapas

EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Timestamp"]', 'Timestamp', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Your Sex?"]', 'Sexo', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Your Matric (grade 12) Average  GPA (in %)"]', 'Matric_GPA', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["What year were you in last year (2023) ?"]', 'Current_semester', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["What faculty does your degree fall under?"]', 'Faculty', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Your 2023 academic year average GPA in % (Ignore if you are 2024 1st year student)"]', 'Academic_Year_GPA_2023', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Your Accommodation Status Last Year (2023)"]', 'Accommodation_Status_2023', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Monthly Allowance in 2023"]', 'Monthly_Allowance_2023', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Were you on scholarship bursary in 2023?"]', 'Scholarship_Bursary_2023', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Additional amount of studying (in hrs) per week"]', 'Additional_Studying_Hours_Per_Week', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["How often do you go out partying socialising during the week? "]', 'Frequency_Partying_Socializing_Week', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["On a night out]', 'Night_Out', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].[ how many alcoholic drinks do you consume?"]', 'Alcoholic_Drinks_Consumed', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["How many classes do you miss per week due to alcohol reasons]', 'Classes_Missed_Per_Week_Alcohol_Reasons', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].[ (i e  being hungover or too tired?)"]', 'Hungover_Too_Tired', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["How many modules have you failed thus far into your studies?"]', 'Modules_Failed', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Are you currently in a romantic relationship?"]', 'In_Romantic_Relationship', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["Do your parents approve alcohol consumption?"]', 'Parents_Approve_Alcohol', 'COLUMN';
EXEC sp_rename 'AlcoholOnStudents.dbo.[Stats survey].["How strong is your relationship with your parent s?"]', 'Relationship_with_Parents', 'COLUMN';


-- 0.2 Removendo " dos campos

UPDATE [Stats survey]
SET 
	Timestamp = REPLACE(Timestamp, '"', ''),
    Sexo = REPLACE(Sexo, '"', ''),
    Matric_GPA = REPLACE(Matric_GPA, '"', ''),
	[Last_Year] = REPLACE([Last_Year], '"', ''),
	[Faculty] = REPLACE([Faculty], '"', ''),
	[Academic_Year_GPA_2023] = REPLACE([Academic_Year_GPA_2023], '"', ''),
	[Accommodation_Status_2023] = REPLACE([Accommodation_Status_2023], '"', ''),
	[Monthly_Allowance_2023] = REPLACE([Monthly_Allowance_2023], '"', ''),
	[Scholarship_Bursary_2023] = REPLACE([Scholarship_Bursary_2023], '"', ''),
	[Additional_Studying_Hours_Per_Week] = REPLACE([Additional_Studying_Hours_Per_Week], '"', ''),
	[Frequency_Partying_Socializing_Week] = REPLACE([Frequency_Partying_Socializing_Week], '"', ''),
	[Night_Out] = REPLACE([Night_Out], '"', ''),
	[Alcoholic_Drinks_Consumed] = REPLACE([Alcoholic_Drinks_Consumed], '"', ''),
	[Classes_Missed_Per_Week_Alcohol_Reasons] = REPLACE([Classes_Missed_Per_Week_Alcohol_Reasons], '"', ''),
	[Hungover_Too_Tired] = REPLACE([Hungover_Too_Tired], '"', ''),
	[Modules_Failed] = REPLACE([Modules_Failed], '"', ''),
	[In_Romantic_Relationship] = REPLACE([In_Romantic_Relationship], '"', ''),
	[Parents_Approve_Alcohol] = REPLACE([Parents_Approve_Alcohol], '"', ''),
	[Relationship_with_Parents] = REPLACE([Relationship_with_Parents], '"', '');


-- ##########################################


/*

	## 1.0 Exploração de dados

*/

 
-- Visão geral
select top 10 *
from [Stats survey]


-- 1.1 - Procurando inconsistências nos dados
select 
	Sexo,
	count(Sexo) as contagem
From [Stats survey]
group by sexo


-- 1.2 - Validando o porque dos dados estarem vazios.
SELECT *
FROM [Stats survey]
WHERE sexo NOT IN ('Female', 'Male');




-- ##########################################


/*

	### - 2.0 Limpeza e pré-processamento

*/


-- 2.1 - Separando a coluna de Timestamp em data e hora

select
	Timestamp
from
	[Stats survey]

-- 2.1.2 - Criando as colunas de tempo e data
ALTER TABLE [Stats survey]
ADD Timestamp_Date DATE,
    Timestamp_Time TIME;


-- 2.1.3 - Adicionando a data da coluna Timestamp para Timestamp_Date
UPDATE [Stats survey]
SET 
    Timestamp_Date = CONVERT(DATE, SUBSTRING(Timestamp, 1, 10))


-- 2.1.4 - Usando CTE e convertendo o formato de hora AM/PM para 24H
WITH coluna_hora AS (
    SELECT
        SUBSTRING([Timestamp], 11, 12) AS hora,
		[Timestamp] as Horarios
    FROM
        [Stats survey]
)
SELECT 
    CASE 
        WHEN RIGHT(subquery.hora, 2) = 'pm' AND LEFT(subquery.hora, 2) != '12' THEN
            CONVERT(VARCHAR(8), DATEADD(HOUR, 12, CONVERT(DATETIME, subquery.hora)), 108)
        WHEN RIGHT(subquery.hora, 2) = 'am' AND LEFT(subquery.hora, 2) = '12' THEN
            '00' + SUBSTRING(subquery.hora, 3, 5)
        ELSE
            CONVERT(VARCHAR(8), CONVERT(DATETIME, subquery.hora), 108)
    END AS hora_24h
FROM
    coluna_hora as subquery;


-- 2.1.5 - Atualizando a coluna Timestamp_Time
UPDATE s
SET s.[Timestamp_Time] = 
    CASE 
        WHEN RIGHT(subquery.hora, 2) = 'PM' AND LEFT(subquery.hora, 2) != '12' THEN
            CONVERT(VARCHAR(8), DATEADD(HOUR, 12, CONVERT(DATETIME, subquery.hora)), 108)
        WHEN RIGHT(subquery.hora, 2) = 'AM' AND LEFT(subquery.hora, 2) = '12' THEN
            '00' + SUBSTRING(subquery.hora, 3, 5)
        ELSE
            CONVERT(VARCHAR(8), CONVERT(DATETIME, subquery.hora), 108)
    END
FROM [Stats survey] s
CROSS APPLY (
    SELECT SUBSTRING(s.[Timestamp], 11, 12) AS hora
) AS subquery;



-- ##########################################



/*

	## - 3.0 - Transformação dos dados

*/



-- 3.1 - Dados faltantes em Faculty
select 
	*
From 
	[Stats survey]
where 
	Faculty = ''

-- 3.2 - São 5 dados faltantes de Faculty, como é um valor bem baixo e não iria alterar significativamente a minha analise, para não descarta-los, irei aplicar a métodologia de imputação de dados, irei atribuir os dados vazios ao conjunto de dados que mais se repete (Economic & Management Sciences)

UPDATE [Stats survey]
SET Faculty = 'Economic & Management Sciences'
WHERE Faculty = '';


-- 3.3 Padronizando as colunas "Addicional_Studying_Hours_Per_Week", "Frequency_Partying_Socializing_Week", "[Alcoholic_Drinks_Consumed]", "[Classes_Missed_Per_Week_Alcohol_Reasons]".
-- Irei padrozinar as colunas acima para a média, como os dados estão com medidas "Entre 3-5h", faz sentido adicionar a média para todos os campo.


-- 3.3.1 - Verificando os dados
select 
	Additional_Studying_Hours_Per_Week, count(Additional_Studying_Hours_Per_Week) as ctg
from 
	[Stats survey]
 group by
 Additional_Studying_Hours_Per_Week
-- # OBS - Temos 46 contagens de dados como " etc..)". Irei calcular a média de todos os outros campos e em seguida, atribuir o resultado para os campos " etc...)" 

-- 3.3.2 - Convertendo para média.
WITH Horas_Estudo AS (
    SELECT 
        Additional_Studying_Hours_Per_Week, 
        CASE 
            WHEN Additional_Studying_Hours_Per_Week = '0' THEN 0
            WHEN Additional_Studying_Hours_Per_Week = '1-3' THEN 2
            WHEN Additional_Studying_Hours_Per_Week = '3-5' THEN 4
            WHEN Additional_Studying_Hours_Per_Week = '5-8' THEN 6.5
            WHEN Additional_Studying_Hours_Per_Week = '8+' THEN 9
            ELSE NULL
        END AS Horas_Convertidas, 
        COUNT(*) AS ctg
    FROM 
        [Stats survey]
    GROUP BY
        Additional_Studying_Hours_Per_Week
)
SELECT 
    Additional_Studying_Hours_Per_Week, 
    Horas_Convertidas,
    ctg
FROM 
    Horas_Estudo;

-- 3.3.3 Criando nova coluna que ira receber a média feita pela coluna de "Studying_Hour"
ALTER TABLE [Stats survey]
ADD AVG_Studying_Hours float;

-- 3.3.4 Adicionando os dados na coluna
UPDATE [Stats survey]
SET AVG_Studying_Hours = 
    CASE 
        WHEN Additional_Studying_Hours_Per_Week = '0' THEN 0
        WHEN Additional_Studying_Hours_Per_Week = '1-3' THEN 2
        WHEN Additional_Studying_Hours_Per_Week = '3-5' THEN 4
        WHEN Additional_Studying_Hours_Per_Week = '5-8' THEN 6.5
        WHEN Additional_Studying_Hours_Per_Week = '8+' THEN 9
        ELSE NULL
    END;


-- ## 3.3.5 Verificando coluna Frequency_Partying

select 
	Frequency_Partying_Socializing_Week, count(Frequency_Partying_Socializing_Week) as ctg
from 
	[Stats survey]
 group by
	Frequency_Partying_Socializing_Week

-- 3.5.6 Convertendo Frequency_Partying para média
WITH Frequencia_Festa AS (
    SELECT 
        Frequency_Partying_Socializing_Week, 
        CASE 
            WHEN Frequency_Partying_Socializing_Week = '0' THEN 0
            WHEN Frequency_Partying_Socializing_Week = '1' THEN 1
            WHEN Frequency_Partying_Socializing_Week = '1-3' THEN 2
            WHEN Frequency_Partying_Socializing_Week = '2' THEN 2
            WHEN Frequency_Partying_Socializing_Week = '3' THEN 3
            WHEN Frequency_Partying_Socializing_Week = '3-5' THEN 4
            WHEN Frequency_Partying_Socializing_Week = '4+' THEN 4
            WHEN Frequency_Partying_Socializing_Week = '5-8' THEN 6.5
            WHEN Frequency_Partying_Socializing_Week = '8+' THEN 9
            ELSE -1 -- Valores do final de semana
        END AS Frequencia_Festa_media
    FROM 
        [Stats survey]
)
SELECT 
    Frequencia_Festa_media
FROM 
    Frequencia_Festa;


-- 3.5.7 Criando nova coluna que ira receber a média feita pela coluna de "Frequency_Partying"
ALTER TABLE [Stats survey]
ADD AVG_Frequency_Partying float;

-- 3.3.4 Adicionando os dados na coluna
UPDATE [Stats survey]
SET AVG_Frequency_Partying = 
    CASE 
		WHEN Frequency_Partying_Socializing_Week = '0' THEN 0
		WHEN Frequency_Partying_Socializing_Week = '1' THEN 1
        WHEN Frequency_Partying_Socializing_Week = '1-3' THEN 2
        WHEN Frequency_Partying_Socializing_Week = '2' THEN 2
        WHEN Frequency_Partying_Socializing_Week = '3' THEN 3
        WHEN Frequency_Partying_Socializing_Week = '3-5' THEN 4
        WHEN Frequency_Partying_Socializing_Week = '4+' THEN 4
        WHEN Frequency_Partying_Socializing_Week = '5-8' THEN 6.5
        WHEN Frequency_Partying_Socializing_Week = '8+' THEN 9
        ELSE -1 -- Valores do final de semana
    END;





select 
	*
From 
	[Stats survey]





/*

	## 4.0 Análise

*/