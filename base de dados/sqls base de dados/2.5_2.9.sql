-- ==================================================================================
-- PERGUNTA 2.5
-- "Liste os armazéns que, no período de 01/03/2018 a 15/10/2018, têm o número total 
-- de encomendas pendentes, maior do que qualquer armazém da cidade do Porto"
-- ==================================================================================

-- Raciocínio:
-- 1. Contar encomendas 'Pendentes' no intervalo de datas indicado, agrupando por Armazém.
--    (A ligação é NotaEncomenda -> Funcionario -> Armazem).
-- 2. Na cláusula HAVING, comparar essa contagem com uma subquery.
-- 3. A subquery conta as encomendas pendentes de CADA armazém que fica na 'Zona Geográfica' 
--    do Porto (ou cujo nome/morada contenha 'Porto', assumindo aqui o filtro por nome).
-- 4. O operador '> ALL' garante que o valor é maior que o máximo encontrado no Porto.

SELECT A.Nome, COUNT(NE.Numero_Encomenda) AS Total_Pendentes
FROM Armazem A
JOIN Funcionario F ON A.Codigo_Armazem = F.Codigo_Armazem
JOIN NotaEncomenda NE ON F.Numero_Funcionario = NE.Numero_Vendedor
WHERE NE.Estado = 'Pendente' 
  AND NE.Data_Encomenda BETWEEN '2018-03-01' AND '2018-10-15'
GROUP BY A.Nome
HAVING COUNT(NE.Numero_Encomenda) > ALL (
    SELECT COUNT(NE2.Numero_Encomenda)
    FROM NotaEncomenda NE2
    JOIN Funcionario F2 ON NE2.Numero_Vendedor = F2.Numero_Funcionario
    JOIN Armazem A2 ON F2.Codigo_Armazem = A2.Codigo_Armazem
    WHERE A2.Morada LIKE '%Porto%' OR A2.Nome LIKE '%Porto%' -- Filtro por cidade
      AND NE2.Estado = 'Pendente'
      AND NE2.Data_Encomenda BETWEEN '2018-03-01' AND '2018-10-15'
    GROUP BY A2.Codigo_Armazem
);

-- ==================================================================================
-- PERGUNTA 2.6
-- "Liste os vendedores (número, nome e zona) que em 2015, registaram encomendas de 
-- artigos com valor superior a 1000€ e que nunca venderam o produto de nome 'Produto espetacular.'"
-- ==================================================================================

-- Raciocínio:
-- 1. Primeira parte (Candidatos): Selecionar vendedores que tiveram encomendas em 2015 
--    cujo valor total (Soma de Qtd * Preço) seja > 1000.
-- 2. Segunda parte (Exclusão): Usar o operador EXCEPT (ou NOT IN) para remover dessa lista
--    os vendedores que, em qualquer momento (não apenas 2015), venderam o 'Produto espetacular.'.

SELECT F.Numero_Funcionario, F.Nome, ZG.Nome AS Zona
FROM Funcionario F
JOIN ZonaGeografica ZG ON F.ID_ZonaGeo = ZG.ID_ZonaGeo
JOIN NotaEncomenda NE ON F.Numero_Funcionario = NE.Numero_Vendedor
JOIN LinhaEncomenda LE ON NE.Numero_Encomenda = LE.Numero_Encomenda
JOIN Artigo A ON LE.Referencia_Artigo = A.Referencia
WHERE YEAR(NE.Data_Encomenda) = 2015
GROUP BY F.Numero_Funcionario, F.Nome, ZG.Nome, NE.Numero_Encomenda
HAVING SUM(LE.Quantidade_Encomendada * A.Preco_Venda_Atual) > 1000

EXCEPT -- Remove quem vendeu o produto proibido

SELECT F2.Numero_Funcionario, F2.Nome, ZG2.Nome
FROM Funcionario F2
JOIN ZonaGeografica ZG2 ON F2.ID_ZonaGeo = ZG2.ID_ZonaGeo
JOIN NotaEncomenda NE2 ON F2.Numero_Funcionario = NE2.Numero_Vendedor
JOIN LinhaEncomenda LE2 ON NE2.Numero_Encomenda = LE2.Numero_Encomenda
JOIN Artigo A2 ON LE2.Referencia_Artigo = A2.Referencia
WHERE A2.Nome = 'Produto espetacular.';

-- ==================================================================================
-- PERGUNTA 2.7
-- "Liste o produto e volume mensal encomendado, para o ano 2019, dos produtos que 
-- estão em armazéns cujo stock está pelo menos 50% acima do stock mínimo."
-- ==================================================================================

-- Raciocínio:
-- 1. Filtrar as vendas pelo ano 2019.
-- 2. Calcular o volume total (Soma da Qtd Encomendada * Volume Unitário do Artigo).
-- 3. Agrupar por Mês (MONTH) e por Artigo.
-- 4. O filtro principal está no WHERE/IN: O artigo tem de existir num armazém onde 
--    a Quantidade em Stock > Stock Minimo * 1.5 (50% acima).
--    Precisamos somar o stock de todas as zonas físicas desse armazém para comparar com o mínimo.

SELECT 
    A.Nome AS Nome_Produto, 
    MONTH(NE.Data_Encomenda) AS Mes,
    SUM(LE.Quantidade_Encomendada * A.Volume_Unitario) AS Volume_Mensal_Encomendado
FROM Artigo A
JOIN LinhaEncomenda LE ON A.Referencia = LE.Referencia_Artigo
JOIN NotaEncomenda NE ON LE.Numero_Encomenda = NE.Numero_Encomenda
WHERE YEAR(NE.Data_Encomenda) = 2019
  AND A.Referencia IN (
      -- Subquery: Artigos que cumprem a regra dos 50% acima do mínimo num dado armazém
      SELECT S.Referencia_Artigo
      FROM Stock S
      JOIN ZonaFisica ZF ON S.ID_ZonaFisica = ZF.ID_ZonaFisica
      JOIN Artigo_Armazem_Parametros AAP ON S.Referencia_Artigo = AAP.Referencia_Artigo 
                                         AND ZF.Codigo_Armazem = AAP.Codigo_Armazem
      GROUP BY S.Referencia_Artigo, ZF.Codigo_Armazem, AAP.Stock_Minimo
      HAVING SUM(S.Quantidade) >= (AAP.Stock_Minimo * 1.5)
  )
GROUP BY A.Nome, MONTH(NE.Data_Encomenda);

-- ==================================================================================
-- PERGUNTA 2.8
-- "Liste o nome do empregado que não é supervisor e que efetuou notas de encomendas 
-- em maior número do que todos os supervisores que possuem um salário mensal entre 1000€ e 3000€."
-- ==================================================================================

-- Raciocínio:
-- 1. Filtrar empregados que NÃO aparecem na coluna 'Codigo_Supervisor' de ninguém.
-- 2. Contar as encomendas feitas por esse empregado.
-- 3. Comparar essa contagem (> ALL) com a contagem de encomendas de cada supervisor 
--    que cumpra o critério salarial (1000-3000).

SELECT F.Nome, COUNT(NE.Numero_Encomenda) AS Total_Encomendas
FROM Funcionario F
JOIN NotaEncomenda NE ON F.Numero_Funcionario = NE.Numero_Vendedor
WHERE F.Numero_Funcionario NOT IN (SELECT DISTINCT Codigo_Supervisor FROM Funcionario WHERE Codigo_Supervisor IS NOT NULL)
GROUP BY F.Nome
HAVING COUNT(NE.Numero_Encomenda) > ALL (
    -- Contagem de encomendas dos supervisores com salário alvo
    SELECT COUNT(NE2.Numero_Encomenda)
    FROM Funcionario F_Sup
    JOIN NotaEncomenda NE2 ON F_Sup.Numero_Funcionario = NE2.Numero_Vendedor
    WHERE F_Sup.Numero_Funcionario IN (SELECT DISTINCT Codigo_Supervisor FROM Funcionario)
      AND F_Sup.Salario_Mensal BETWEEN 1000 AND 3000
    GROUP BY F_Sup.Numero_Funcionario
);

-- ==================================================================================
-- PERGUNTA 2.9
-- "Liste as guias de saída, entre o mês de Junho e Agosto de 2018, cuja hora de 
-- elaboração é inferior às 10 horas da manhã e com uma diferença entre a data da 
-- encomenda e a data da guia de saída superior a 10 dias."
-- ==================================================================================

-- Raciocínio:
-- 1. Filtrar intervalo de datas (Junho a Agosto 2018).
-- 2. Usar DATEPART(HOUR, ...) para verificar se é < 10.
-- 3. Usar DATEDIFF(DAY, Data_Encomenda, Data_Guia) para verificar se passaram > 10 dias.
-- 4. Fazer JOIN com NotaEncomenda para ter acesso à data original da encomenda.

SELECT GS.ID_Guia, GS.Data_Hora_Elaboracao, NE.Data_Encomenda
FROM GuiaSaida GS
JOIN NotaEncomenda NE ON GS.Numero_Encomenda = NE.Numero_Encomenda
WHERE GS.Data_Hora_Elaboracao >= '2018-06-01' 
  AND GS.Data_Hora_Elaboracao <= '2018-08-31'
  AND DATEPART(HOUR, GS.Data_Hora_Elaboracao) < 10
  AND DATEDIFF(DAY, NE.Data_Encomenda, GS.Data_Hora_Elaboracao) > 10;