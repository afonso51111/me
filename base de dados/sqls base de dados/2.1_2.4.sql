-- ==================================================================================
-- PERGUNTA 2.1 [cite: 851]
-- "Liste para cada armazém, todas as zonas físicas onde atualmente se encontra o artigo mais encomendado."
-- ==================================================================================

-- Raciocínio:
-- 1. Primeiro, preciso descobrir qual é o artigo "mais encomendado". Faço isso somando 
--    as quantidades na tabela LinhaEncomenda e ordenando de forma decrescente (TOP 1).
-- 2. Depois, com esse artigo identificado, vou à tabela de Stock ver em que Zonas Físicas ele está.
-- 3. Finalmente, faço JOIN com Armazem para mostrar o nome do armazém e da zona.

SELECT 
    A.Nome AS Nome_Armazem, 
    ZF.Codigo_Identificacao AS Zona_Fisica,
    ART.Nome AS Artigo_Mais_Vendido
FROM Stock S
JOIN ZonaFisica ZF ON S.ID_ZonaFisica = ZF.ID_ZonaFisica
JOIN Armazem A ON ZF.Codigo_Armazem = A.Codigo_Armazem
JOIN Artigo ART ON S.Referencia_Artigo = ART.Referencia
WHERE S.Referencia_Artigo = (
    -- Subquery para achar o ID do artigo mais vendido
    SELECT TOP 1 Referencia_Artigo
    FROM LinhaEncomenda
    GROUP BY Referencia_Artigo
    ORDER BY SUM(Quantidade_Encomendada) DESC
);


-- ==================================================================================
-- PERGUNTA 2.2 [cite: 853]
-- "Liste o nome dos armazéns que têm em stock todos os artigos que existem no armazém que possui o maior número de empregados."
-- ==================================================================================

-- Raciocínio:
-- Esta é uma clássica "Divisão Relacional".
-- 1. Identificar o "Armazém Alvo" (o que tem mais empregados) usando TOP 1 e COUNT na tabela Funcionario.
-- 2. Identificar todos os artigos distintos que existem nesse Armazém Alvo (via Stock e ZonaFisica).
-- 3. A query principal procura armazéns onde NÃO EXISTA nenhum artigo do "Armazém Alvo" que falte no seu stock.
--    (Basicamente: "Dá-me os armazéns onde a contagem dos artigos coincidentes é igual ao total de artigos do armazém alvo").

SELECT A.Nome
FROM Armazem A
JOIN ZonaFisica ZF ON A.Codigo_Armazem = ZF.Codigo_Armazem
JOIN Stock S ON ZF.ID_ZonaFisica = S.ID_ZonaFisica
WHERE S.Referencia_Artigo IN (
    -- Lista de artigos do armazém com mais empregados
    SELECT DISTINCT S2.Referencia_Artigo
    FROM Stock S2
    JOIN ZonaFisica ZF2 ON S2.ID_ZonaFisica = ZF2.ID_ZonaFisica
    WHERE ZF2.Codigo_Armazem = (
        SELECT TOP 1 Codigo_Armazem
        FROM Funcionario
        GROUP BY Codigo_Armazem
        ORDER BY COUNT(*) DESC
    )
)
GROUP BY A.Nome
HAVING COUNT(DISTINCT S.Referencia_Artigo) = (
    -- Contagem total de artigos únicos do armazém com mais empregados
    SELECT COUNT(DISTINCT S3.Referencia_Artigo)
    FROM Stock S3
    JOIN ZonaFisica ZF3 ON S3.ID_ZonaFisica = ZF3.ID_ZonaFisica
    WHERE ZF3.Codigo_Armazem = (
        SELECT TOP 1 Codigo_Armazem
        FROM Funcionario
        GROUP BY Codigo_Armazem
        ORDER BY COUNT(*) DESC
    )
);


-- ==================================================================================
-- PERGUNTA 2.3 [cite: 855]
-- "Liste as zonas físicas do armazém designado de XPTO, que possuem a maior quantidade de artigos em stock."
-- ==================================================================================

-- NOTA: Como não temos um armazém chamado "XPTO", vou usar 'Armazém Porto Principal' 
-- (que criámos nos dados) para a query funcionar. No trabalho, substitui pelo nome que quiseres.

-- Raciocínio:
-- 1. Filtrar as Zonas Físicas que pertencem ao armazém específico.
-- 2. Somar a quantidade de stock (SUM) agrupado por Zona.
-- 3. Ordenar descrescente e pegar na primeira (TOP 1).
-- 4. Uso ISNULL na soma para garantir que não devolve NULL.

SELECT TOP 1 
    ZF.Codigo_Identificacao, 
    ISNULL(SUM(S.Quantidade), 0) AS Quantidade_Total
FROM ZonaFisica ZF
LEFT JOIN Stock S ON ZF.ID_ZonaFisica = S.ID_ZonaFisica
JOIN Armazem A ON ZF.Codigo_Armazem = A.Codigo_Armazem
WHERE A.Nome = 'Armazém Porto Principal' -- Substituir por 'XPTO' se criares um com esse nome
GROUP BY ZF.Codigo_Identificacao
ORDER BY Quantidade_Total DESC;


-- ==================================================================================
-- PERGUNTA 2.4 [cite: 857]
-- "Liste as zonas (nome e código armazém) que tenham todo o seu volume ocupado."
-- ==================================================================================

-- Raciocínio:
-- 1. Calcular o volume ocupado em cada zona: Somatório de (Quantidade em Stock * Volume Unitário do Artigo).
-- 2. Comparar esse volume ocupado com a Capacidade_Volume da tabela ZonaFisica.
-- 3. Listar apenas aquelas onde Volume Ocupado >= Capacidade Total.
-- 4. Ordenar conforme pedido: Crescente de Armazém, Decrescente de Zona.

SELECT 
    ZF.Codigo_Identificacao AS Nome_Zona, 
    ZF.Codigo_Armazem
FROM ZonaFisica ZF
JOIN Stock S ON ZF.ID_ZonaFisica = S.ID_ZonaFisica
JOIN Artigo ART ON S.Referencia_Artigo = ART.Referencia
GROUP BY ZF.Codigo_Identificacao, ZF.Codigo_Armazem, ZF.Capacidade_Volume
HAVING SUM(S.Quantidade * ART.Volume_Unitario) >= ZF.Capacidade_Volume
ORDER BY ZF.Codigo_Armazem ASC, ZF.Codigo_Identificacao DESC;