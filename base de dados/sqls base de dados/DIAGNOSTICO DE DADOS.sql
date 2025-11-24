-- === DIAGNÓSTICO DE DADOS ===

-- 1. Contagem de Registos (Têm de ser >= 30)
SELECT 'Artigos' AS Tabela, COUNT(*) AS Total FROM Artigo
UNION ALL
SELECT 'Clientes', COUNT(*) FROM Cliente
UNION ALL
SELECT 'Funcionarios', COUNT(*) FROM Funcionario
UNION ALL
SELECT 'Armazens', COUNT(*) FROM Armazem
UNION ALL
SELECT 'Encomendas', COUNT(*) FROM NotaEncomenda;

-- 2. Verificar se o "Produto Espetacular" existe (Para a pergunta 2.6)
SELECT Referencia, Nome, Preco_Venda_Atual 
FROM Artigo 
WHERE Nome LIKE '%espetacular%';

-- 3. Verificar se existe a Venda antiga de 2015 (Para a pergunta 2.6)
SELECT * FROM NotaEncomenda 
WHERE YEAR(Data_Encomenda) = 2015;

-- 4. Verificar se há Guias de Saída em Junho de 2018 (Para a pergunta 2.9)
SELECT * FROM GuiaSaida 
WHERE Data_Hora_Elaboracao BETWEEN '2018-06-01' AND '2018-06-30';