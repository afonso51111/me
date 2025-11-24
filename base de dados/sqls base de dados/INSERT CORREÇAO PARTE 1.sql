-- 1. Limpar os dados da ZonaFisica que ficaram mal inseridos (Usamos DELETE em vez de TRUNCATE)
DELETE FROM ZonaFisica;

-- (Opcional) Reiniciar o contador do ID da ZonaFisica para começar no 1
DBCC CHECKIDENT ('ZonaFisica', RESEED, 0);

-- 2. Inserir as Zonas Físicas Corretas
INSERT INTO ZonaFisica (Codigo_Identificacao, Capacidade_Volume, Codigo_Armazem) VALUES
('CORREDOR-A', 1000, 'ARM-PORTO-01'), ('CORREDOR-B', 1000, 'ARM-PORTO-01'),
('CORREDOR-A', 800, 'ARM-BRAGA-01'), ('CORREDOR-B', 800, 'ARM-BRAGA-01'),
('ESTANTE-1', 500, 'ARM-VILA-01'), ('ESTANTE-2', 500, 'ARM-VILA-01'),
('PISO-0', 2000, 'ARM-COIMBRA'), ('PISO-1', 2000, 'ARM-COIMBRA'),
('ZONA-FRIO', 300, 'ARM-LISBOA'), ('ZONA-SECA', 1500, 'ARM-LISBOA');

-- Preencher o resto até 30 com zonas genéricas
DECLARE @i INT = 11;
WHILE @i <= 30
BEGIN
    INSERT INTO ZonaFisica (Codigo_Identificacao, Capacidade_Volume, Codigo_Armazem)
    VALUES ('ZONA-GEN-' + CAST(@i AS VARCHAR), 100.00, 'ARM-PORTO-01');
    SET @i = @i + 1;
END;

-- 3. INSERIR ARTIGOS (Isto não chegou a correr da última vez)
INSERT INTO Artigo (Referencia, Nome, Descricao, Preco_Compra_Atual, Preco_Venda_Atual, Unidade_Representacao, Volume_Unitario) VALUES
('ART001', 'Martelo de Aço', 'Martelo resistente 500g', 5.00, 12.50, 'unidade', 0.002),
('ART002', 'Berbequim X500', 'Berbequim 500W com fio', 25.00, 55.00, 'unidade', 0.015),
('ART003', 'Caixa Parafusos M5', 'Caixa com 100 parafusos M5', 2.00, 4.50, 'caixa', 0.001),
('ART004', 'Tinta Branca 15L', 'Lata de tinta interior', 30.00, 65.00, 'lata', 0.020),
('ART005', 'Lixa P100', 'Folha de lixa grão 100', 0.10, 0.50, 'unidade', 0.0001),
('ART006', 'Produto espetacular.', 'O tal produto do enunciado', 400.00, 950.00, 'unidade', 0.5);

-- Gerar restantes artigos até 30
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