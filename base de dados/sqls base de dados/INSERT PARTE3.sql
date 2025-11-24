-- ==================================================================================
-- 7. GERAR ENCOMENDAS (Vendas)
-- ==================================================================================

-- 7.1 Inserir 35 Encomendas Genéricas para fazer volume (Datas de 2024/2025)
DECLARE @i INT = 1;
WHILE @i <= 35
BEGIN
    INSERT INTO NotaEncomenda (Data_Encomenda, Estado, Codigo_Cliente, Numero_Vendedor)
    VALUES (
        DATEADD(DAY, -@i, GETDATE()), -- Datas recentes
        'Processada', 
        (1 + (@i % 5)), -- Clientes 1 a 5
        100 + (@i % 3)  -- Vendedores 100, 101, 102
    );
    SET @i = @i + 1;
END;

-- 7.2 Inserir Linhas de Encomenda para todas estas encomendas
-- (Cada encomenda leva o Artigo 1 e o Artigo 2 para simplificar)
INSERT INTO LinhaEncomenda (Numero_Encomenda, Referencia_Artigo, Quantidade_Encomendada)
SELECT Numero_Encomenda, 'ART001', 5 FROM NotaEncomenda;

INSERT INTO LinhaEncomenda (Numero_Encomenda, Referencia_Artigo, Quantidade_Encomendada)
SELECT Numero_Encomenda, 'ART002', 2 FROM NotaEncomenda;

-- ==================================================================================
-- 8. TRUQUE DE MESTRE: Alterar dados para responder às perguntas do enunciado
-- ==================================================================================

-- CASO 1: Pergunta 2.6 - Venda em 2015 com valor > 1000€
-- Vamos pegar na Encomenda #1 e mudá-la para 2015
UPDATE NotaEncomenda 
SET Data_Encomenda = '2015-05-20', Numero_Vendedor = 101 
WHERE Numero_Encomenda = 1;

-- Adicionar uma linha de encomenda valiosa à Encomenda #1
-- (O ART006 custa 950€, 2 unidades = 1900€ -> Cumpre o requisito > 1000€)
INSERT INTO LinhaEncomenda (Numero_Encomenda, Referencia_Artigo, Quantidade_Encomendada)
VALUES (1, 'ART006', 2); 


-- CASO 2: Pergunta 2.9 - Guia entre Junho e Agosto 2018, hora < 10h, diff > 10 dias
-- Vamos preparar a Encomenda #2 para isto.
UPDATE NotaEncomenda 
SET Data_Encomenda = '2018-05-01', Estado = 'Processada' 
WHERE Numero_Encomenda = 2;


-- CASO 3: Pergunta 2.5 - Pendentes entre Março e Outubro 2018
-- Vamos mudar a Encomenda #3 e #4 para pendentes nessa data
UPDATE NotaEncomenda 
SET Data_Encomenda = '2018-06-01', Estado = 'Pendente' 
WHERE Numero_Encomenda IN (3, 4);


-- CASO 4: Pergunta 2.7 - Vendas em 2019
UPDATE NotaEncomenda 
SET Data_Encomenda = '2019-03-15' 
WHERE Numero_Encomenda = 5;

-- ==================================================================================
-- 9. GERAR GUIAS DE SAÍDA E LOGÍSTICA
-- ==================================================================================

-- 9.1 Gerar Guias para as Encomendas Processadas (Ignora as Pendentes)
INSERT INTO GuiaSaida (Data_Hora_Elaboracao, Numero_Funcionario_Resp, Numero_Encomenda)
SELECT 
    DATEADD(DAY, 2, Data_Encomenda), -- Guia feita 2 dias depois da encomenda
    200, -- Feito pelo Chefe do Armazém (ID 200)
    Numero_Encomenda
FROM NotaEncomenda
WHERE Estado = 'Processada';

-- 9.2 "Arranjar" a Guia da Encomenda #2 para a Pergunta 2.9
-- Tem de ser em Junho/Agosto 2018 e antes das 10h da manhã
UPDATE GuiaSaida
SET Data_Hora_Elaboracao = '2018-06-15 09:30:00' -- Manhã de Junho
WHERE Numero_Encomenda = 2;


-- 9.3 Inserir Linhas da Guia de Saída (Detalhe de onde saiu o material)
-- (Vamos assumir que sai tudo da ZonaFisica 1 para simplificar o script)
INSERT INTO LinhaGuiaSaida (ID_Guia, Referencia_Artigo, ID_ZonaFisica_Origem, Quantidade_Retirada)
SELECT 
    G.ID_Guia, 
    LE.Referencia_Artigo, 
    1, -- Sai da Zona 1 (Corredor A)
    LE.Quantidade_Encomendada
FROM GuiaSaida G
JOIN LinhaEncomenda LE ON G.Numero_Encomenda = LE.Numero_Encomenda;


-- 9.4 Gerar Transportes
-- Para cada Guia, associar uma transportadora
INSERT INTO Transporte (ID_Transportadora, ID_Guia, Data_Hora_Transporte, Horas_Utilizacao)
SELECT 
    (1 + (ID_Guia % 5)), -- Transportadora rotativa
    ID_Guia,
    DATEADD(HOUR, 2, Data_Hora_Elaboracao), -- Transporte 2h depois da guia
    4.5 -- Duração
FROM GuiaSaida;

GO