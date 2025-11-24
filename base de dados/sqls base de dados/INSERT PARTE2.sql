-- ==================================================================================
-- 4. INSERIR STOCK (Artigos nas Zonas) e HISTÓRICO DE PREÇOS
-- ==================================================================================

-- Inserir Stock (Vamos encher as zonas criadas com artigos)
DECLARE @zona_id INT = 1;
DECLARE @artigo_ref VARCHAR(20);
DECLARE @qty DECIMAL(10,3);
DECLARE @i INT = 1;

-- Loop para colocar cada um dos 30 artigos em pelo menos 2 zonas diferentes
WHILE @i <= 30
BEGIN
    SET @artigo_ref = (SELECT Referencia FROM (SELECT ROW_NUMBER() OVER (ORDER BY Referencia) as Rn, Referencia FROM Artigo) as T WHERE Rn = @i);
    
    -- Stock na Zona 1 (ou proxima)
    INSERT INTO Stock (ID_ZonaFisica, Referencia_Artigo, Quantidade) VALUES 
    ((@i % 10) + 1, @artigo_ref, 100 + (@i * 5)); 
    
    -- Stock noutra Zona aleatória
    INSERT INTO Stock (ID_ZonaFisica, Referencia_Artigo, Quantidade) VALUES 
    ((@i % 10) + 11, @artigo_ref, 50);

    -- Inserir Histórico de Preços (1 registo antigo + 1 atual implícito no Artigo)
    INSERT INTO HistoricoPreco (Referencia_Artigo, Preco_Venda, Preco_Compra, Data_Inicio, Data_Fim)
    VALUES (@artigo_ref, 10.00 + @i, 5.00 + @i, '2023-01-01', '2024-01-01');
    
    -- Inserir Parametros de Stock Minimo (Para 2 armazéns)
    INSERT INTO Artigo_Armazem_Parametros (Referencia_Artigo, Codigo_Armazem, Stock_Minimo)
    VALUES (@artigo_ref, 'ARM-PORTO-01', 10), (@artigo_ref, 'ARM-LISBOA', 20);

    SET @i = @i + 1;
END;

-- ==================================================================================
-- 5. INSERIR FUNCIONÁRIOS (Com hierarquia Supervisor)
-- ==================================================================================

-- Passo 1: Inserir Supervisores (Mais velhos)
INSERT INTO Funcionario (Numero_Funcionario, Nome, Cartao_Cidadao, NIF, Morada, Salario_Mensal, Data_Nascimento, ID_Categoria, ID_ZonaGeo, Codigo_Armazem, Codigo_Supervisor) VALUES
(100, 'Chefe Silva', '10000001', '200000001', 'Rua A, Porto', 2500.00, '1970-01-01', 1, 1, 'ARM-PORTO-01', NULL), -- Vendedor Chefe
(200, 'Chefe Costa', '10000002', '200000002', 'Rua B, Lisboa', 2600.00, '1975-05-20', 1, 4, 'ARM-LISBOA', NULL);   -- Vendedor Chefe LX

-- Passo 2: Inserir Funcionários Subordinados (Mais novos, mesma categoria para validar regra)
INSERT INTO Funcionario (Numero_Funcionario, Nome, Cartao_Cidadao, NIF, Morada, Salario_Mensal, Data_Nascimento, ID_Categoria, ID_ZonaGeo, Codigo_Armazem, Codigo_Supervisor) VALUES
(101, 'Vendedor João', '10000003', '200000003', 'Rua C', 1200.00, '1990-01-01', 1, 1, 'ARM-PORTO-01', 100),
(102, 'Vendedora Ana', '10000004', '200000004', 'Rua D', 1250.00, '1992-03-15', 1, 1, 'ARM-PORTO-01', 100),
(103, 'Vendedor Pedro', '10000005', '200000005', 'Rua E', 1100.00, '1995-07-20', 1, 1, 'ARM-PORTO-01', 100);

-- Passo 3: Gerar restantes funcionários (até 30)
SET @i = 6;
WHILE @i <= 35
BEGIN
    INSERT INTO Funcionario (Numero_Funcionario, Nome, Cartao_Cidadao, NIF, Morada, Salario_Mensal, Data_Nascimento, ID_Categoria, ID_ZonaGeo, Codigo_Armazem, Codigo_Supervisor) 
    VALUES (
        1000 + @i, 
        'Funcionario ' + CAST(@i AS VARCHAR), 
        '100000' + CAST(@i AS VARCHAR), 
        '2000000' + CAST(@i AS VARCHAR), 
        'Morada Genérica', 
        1000 + (@i * 10), 
        '1990-01-01', 
        2, -- Outra categoria (sem supervisor para simplificar loop)
        1, 
        'ARM-PORTO-01', 
        NULL
    );
    SET @i = @i + 1;
END;

-- ==================================================================================
-- 6. INSERIR CLIENTES
-- ==================================================================================
-- Inserir 5 Clientes Reais
INSERT INTO Cliente (Nome, Morada, Codigo_Postal, Telemovel, NIF, Tipo_Cliente, ID_ZonaGeo) VALUES
('Construtora Norte SA', 'Rua Industrial', '4000-001', '910000000', '501000001', 'VIP', 1),
('Sr. Joaquim Obras', 'Rua da Casa', '4200-001', '910000001', '201000001', 'Pequeno', 1),
('Leroy Fake', 'Av Principal', '1000-001', '910000002', '501000002', 'Grande', 4),
('Cliente do Porto', 'Rua Ribeira', '4000-002', '930000001', '201000002', 'Normal', 1),
('Cliente de Lisboa', 'Rua Augusta', '1100-001', '930000002', '201000003', 'Normal', 4);

-- Gerar mais 25 clientes
SET @i = 6;
WHILE @i <= 30
BEGIN
    INSERT INTO Cliente (Nome, Morada, Codigo_Postal, Telemovel, NIF, Tipo_Cliente, ID_ZonaGeo) 
    VALUES ('Cliente Generico ' + CAST(@i AS VARCHAR), 'Rua ' + CAST(@i AS VARCHAR), '4000-'+CAST(@i AS VARCHAR), '9100000'+CAST(@i AS VARCHAR), '2010000'+CAST(@i AS VARCHAR), 'Pequeno', 1);
    SET @i = @i + 1;
END;