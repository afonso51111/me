-- ==================================================================================
-- 1. INSERIR DADOS AUXILIARES (Zonas, Categorias, Transportadoras)
-- ==================================================================================

-- Inserir 5 Zonas Geográficas Reais + 25 Genéricas para cumprir o requisito de 30
INSERT INTO ZonaGeografica (Nome) VALUES 
('Norte Litoral'), ('Norte Interior'), ('Centro Litoral'), ('Lisboa e Vale do Tejo'), ('Algarve');
-- Loop simples para gerar mais 25 zonas (SQL Server permite este truque)
DECLARE @i INT = 6;
WHILE @i <= 30
BEGIN
    INSERT INTO ZonaGeografica (Nome) VALUES ('Zona Generica ' + CAST(@i AS VARCHAR));
    SET @i = @i + 1;
END;

-- Inserir Categorias Profissionais (5 reais + genéricas)
INSERT INTO Categoria (Designacao) VALUES 
('Vendedor'), ('Fiel de Armazém'), ('Motorista'), ('Supervisor de Logística'), ('Diretor Comercial');
SET @i = 6;
WHILE @i <= 30
BEGIN
    INSERT INTO Categoria (Designacao) VALUES ('Categoria Nivel ' + CAST(@i AS VARCHAR));
    SET @i = @i + 1;
END;

-- Inserir Transportadoras (30 Registos)
-- Nota: NIFs fictícios mas únicos
INSERT INTO Transportadora (Nome, NIF, Contacto_Telefonico, Custo_Hora) VALUES 
('TransIsep Express', '500100100', '910000001', 25.50),
('Bricolage Fast', '500100101', '910000002', 20.00),
('Logistica Norte', '500100102', '910000003', 18.75),
('Rapido e Furioso', '500100103', '910000004', 30.00),
('Camiões do Porto', '500100104', '910000005', 22.00);

-- Gerar o resto das transportadoras
SET @i = 6;
WHILE @i <= 30
BEGIN
    INSERT INTO Transportadora (Nome, NIF, Contacto_Telefonico, Custo_Hora) 
    VALUES ('Transportadora ' + CAST(@i AS VARCHAR), '500100' + CAST(100+@i AS VARCHAR), '9100000' + CAST(@i AS VARCHAR), 20 + (@i % 10));
    SET @i = @i + 1;
END;

-- ==================================================================================
-- 2. INSERIR ARMAZÉNS E ZONAS FÍSICAS
-- ==================================================================================

-- Inserir Armazéns (Vamos criar 30 armazéns espalhados pelas zonas criadas acima)
-- Assume-se que ID_ZonaGeo 1 a 5 existem.
INSERT INTO Armazem (Codigo_Armazem, Nome, Morada, Localizacao_WGS84, ID_ZonaGeo) VALUES
('ARM-PORTO-01', 'Armazém Porto Principal', 'Rua do ISEP, 100', '41.178, -8.608', 1),
('ARM-BRAGA-01', 'Armazém Braga', 'Av da Liberdade, 50', '41.545, -8.426', 1),
('ARM-VILA-01', 'Armazém Vila Real', 'Zona Industrial, 12', '41.300, -7.744', 2),
('ARM-COIMBRA', 'Armazém Coimbra', 'Estrada da Beira, 44', '40.203, -8.410', 3),
('ARM-LISBOA', 'Armazém Lisboa Norte', 'Prior Velho, 5', '38.780, -9.130', 4);

-- Gerar restantes armazéns
SET @i = 6;
WHILE @i <= 30
BEGIN
    INSERT INTO Armazem (Codigo_Armazem, Nome, Morada, ID_ZonaGeo) 
    VALUES ('ARM-GEN-' + CAST(@i AS VARCHAR), 'Armazém Secundário ' + CAST(@i AS VARCHAR), 'Rua Indefinida ' + CAST(@i AS VARCHAR), (1 + (@i % 5)));
    SET @i = @i + 1;
END;

-- Inserir Zonas Físicas (Vamos garantir pelo menos 30 zonas, distribuídas pelos armazéns)
-- Vamos criar 2 zonas por armazém para os primeiros 15 armazéns = 30 zonas.
DECLARE @k INT = 1;
WHILE @k <= 15
BEGIN
    -- Obter código do armazém (exemplo simplificado, assume-se ordem)
    -- Para simplificar o script, vamos inserir fixo baseado nos códigos que geramos
    INSERT INTO ZonaFisica (Codigo_Identificacao, Capacidade_Volume, Codigo_Armazem)
    VALUES 
    ('ZONA-A', 500.00, 'ARM-PORTO-01'), -- Apenas exemplo, o loop em baixo é mais eficaz
    ('ZONA-B', 500.00, 'ARM-PORTO-01'); 
    SET @k = @k + 1;
END;
-- *CORREÇÃO*: O loop acima não funciona bem com strings. Vamos inserir em bloco simples:
TRUNCATE TABLE ZonaFisica; -- Limpar tentativas
INSERT INTO ZonaFisica (Codigo_Identificacao, Capacidade_Volume, Codigo_Armazem) VALUES
('CORREDOR-A', 1000, 'ARM-PORTO-01'), ('CORREDOR-B', 1000, 'ARM-PORTO-01'),
('CORREDOR-A', 800, 'ARM-BRAGA-01'), ('CORREDOR-B', 800, 'ARM-BRAGA-01'),
('ESTANTE-1', 500, 'ARM-VILA-01'), ('ESTANTE-2', 500, 'ARM-VILA-01'),
('PISO-0', 2000, 'ARM-COIMBRA'), ('PISO-1', 2000, 'ARM-COIMBRA'),
('ZONA-FRIO', 300, 'ARM-LISBOA'), ('ZONA-SECA', 1500, 'ARM-LISBOA');

-- Preencher o resto até 30 com zonas genéricas no primeiro armazém
SET @i = 11;
WHILE @i <= 30
BEGIN
    INSERT INTO ZonaFisica (Codigo_Identificacao, Capacidade_Volume, Codigo_Armazem)
    VALUES ('ZONA-GEN-' + CAST(@i AS VARCHAR), 100.00, 'ARM-PORTO-01');
    SET @i = @i + 1;
END;

-- ==================================================================================
-- 3. INSERIR ARTIGOS
-- ==================================================================================
-- Inserir 30 Artigos variados
INSERT INTO Artigo (Referencia, Nome, Descricao, Preco_Compra_Atual, Preco_Venda_Atual, Unidade_Representacao, Volume_Unitario) VALUES
('ART001', 'Martelo de Aço', 'Martelo resistente 500g', 5.00, 12.50, 'unidade', 0.002),
('ART002', 'Berbequim X500', 'Berbequim 500W com fio', 25.00, 55.00, 'unidade', 0.015),
('ART003', 'Caixa Parafusos M5', 'Caixa com 100 parafusos M5', 2.00, 4.50, 'caixa', 0.001),
('ART004', 'Tinta Branca 15L', 'Lata de tinta interior', 30.00, 65.00, 'lata', 0.020),
('ART005', 'Lixa P100', 'Folha de lixa grão 100', 0.10, 0.50, 'unidade', 0.0001),
('ART006', 'Produto espetacular.', 'O tal produto do enunciado', 400.00, 950.00, 'unidade', 0.5); -- Importante para a pergunta 2.6!

-- Gerar restantes artigos
SET @i = 7;
WHILE @i <= 30
BEGIN
    INSERT INTO Artigo (Referencia, Nome, Descricao, Preco_Compra_Atual, Preco_Venda_Atual, Unidade_Representacao, Volume_Unitario)
    VALUES (
        'ART' + RIGHT('000' + CAST(@i AS VARCHAR), 3), 
        'Artigo Genérico ' + CAST(@i AS VARCHAR), 
        'Descrição do artigo ' + CAST(@i AS VARCHAR), 
        10.00 + @i, 
        20.00 + (@i*2), 
        'unidade', 
        0.01
    );
    SET @i = @i + 1;
END;