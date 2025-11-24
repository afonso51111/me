-- Criação da Base de Dados (Opcional, se ainda não tiveres criado)
-- CREATE DATABASE IsepBricolageDB;
-- GO
-- USE IsepBricolageDB;
-- GO

-- ==================================================================================
-- 1. TABELAS DE ESTRUTURA E AUXILIARES
-- ==================================================================================

-- Tabela: Zonas Geográficas
-- Justificação: "IsepBricolage possui vários armazéns... em várias zonas geográficas" 
-- Clientes e Funcionários também estão ligados a esta zona.
CREATE TABLE ZonaGeografica (
    ID_ZonaGeo INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL UNIQUE -- Ex: 'Norte', 'Centro', 'Lisboa'
);

-- Tabela: Categorias Profissionais
-- Justificação: Para normalizar "categoria a que pertence" e validar supervisores.
CREATE TABLE Categoria (
    ID_Categoria INT IDENTITY(1,1) PRIMARY KEY,
    Designacao VARCHAR(50) NOT NULL UNIQUE -- Ex: 'Vendedor', 'Motorista', 'Fiel de Armazém'
);

-- Tabela: Transportadoras
-- Justificação: "interessa registar o nome (único), o NIF também único" 
CREATE TABLE Transportadora (
    ID_Transportadora INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL UNIQUE,
    NIF VARCHAR(9) NOT NULL UNIQUE CHECK (LEN(NIF)=9), -- Validação simples de formato
    Contacto_Telefonico VARCHAR(20) NOT NULL,
    Custo_Hora DECIMAL(10, 2) NOT NULL CHECK (Custo_Hora >= 0)
);

-- ==================================================================================
-- 2. TABELAS DE ARMAZÉNS E ARTIGOS
-- ==================================================================================

-- Tabela: Armazéns
-- Justificação: Identificados por código único, morada, localização 
CREATE TABLE Armazem (
    Codigo_Armazem VARCHAR(20) PRIMARY KEY, -- Código alphanumeric
    Nome VARCHAR(100) NOT NULL,
    Morada VARCHAR(200) NOT NULL,
    Localizacao_WGS84 VARCHAR(100), -- Coordenadas GPS
    ID_ZonaGeo INT NOT NULL,
    FOREIGN KEY (ID_ZonaGeo) REFERENCES ZonaGeografica(ID_ZonaGeo)
);

-- Tabela: Zonas Físicas (dentro do Armazém)
-- Justificação: "Armazém está dividido em várias zonas físicas com uma dada capacidade" 
CREATE TABLE ZonaFisica (
    ID_ZonaFisica INT IDENTITY(1,1) PRIMARY KEY,
    Codigo_Identificacao VARCHAR(20) NOT NULL, -- Ex: 'Corredor A', 'Prateleira 1'
    Capacidade_Volume DECIMAL(12, 3) NOT NULL CHECK (Capacidade_Volume > 0), -- Volume total em m3
    Codigo_Armazem VARCHAR(20) NOT NULL,
    FOREIGN KEY (Codigo_Armazem) REFERENCES Armazem(Codigo_Armazem)
);

-- Tabela: Artigos
-- Justificação: Referência única, nome, preços, etc. 
-- NOTA: Preço atual pode ser guardado aqui para rapidez, mas o histórico é mandatório noutra tabela.
-- Adicionei Volume_Unitario para permitir validação de capacidade da Zona Física.
CREATE TABLE Artigo (
    Referencia VARCHAR(20) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Descricao VARCHAR(500),
    Preco_Compra_Atual DECIMAL(10, 2) NOT NULL CHECK (Preco_Compra_Atual >= 0),
    Preco_Venda_Atual DECIMAL(10, 2) NOT NULL CHECK (Preco_Venda_Atual >= 0),
    Unidade_Representacao VARCHAR(20) NOT NULL, -- Ex: 'kg', 'unidade', 'caixa'
    Volume_Unitario DECIMAL(10, 4) DEFAULT 0 -- Necessário para calcular ocupação da zona
);

-- Tabela: Histórico de Preços
-- Justificação: "interessa manter o histórico dos preços e do intervalo de datas" 
CREATE TABLE HistoricoPreco (
    ID_Historico INT IDENTITY(1,1) PRIMARY KEY,
    Referencia_Artigo VARCHAR(20) NOT NULL,
    Preco_Venda DECIMAL(10, 2) NOT NULL,
    Preco_Compra DECIMAL(10, 2) NOT NULL,
    Data_Inicio DATETIME NOT NULL,
    Data_Fim DATETIME, -- NULL significa que é o preço ativo (ou até ao infinito)
    FOREIGN KEY (Referencia_Artigo) REFERENCES Artigo(Referencia),
    CHECK (Data_Fim >= Data_Inicio) -- Restrição de integridade RI-04 (parcial)
);

-- Tabela: Parâmetros de Artigo por Armazém (Stock Mínimo)
-- Justificação: "stock mínimo... varia de armazém para armazém" 
CREATE TABLE Artigo_Armazem_Parametros (
    Referencia_Artigo VARCHAR(20) NOT NULL,
    Codigo_Armazem VARCHAR(20) NOT NULL,
    Stock_Minimo DECIMAL(10, 3) NOT NULL DEFAULT 0,
    PRIMARY KEY (Referencia_Artigo, Codigo_Armazem),
    FOREIGN KEY (Referencia_Artigo) REFERENCES Artigo(Referencia),
    FOREIGN KEY (Codigo_Armazem) REFERENCES Armazem(Codigo_Armazem)
);

-- Tabela: Stock (Artigo em Zona Física)
-- Justificação: "Artigos podem estar armazenados em várias zonas físicas" 
CREATE TABLE Stock (
    ID_ZonaFisica INT NOT NULL,
    Referencia_Artigo VARCHAR(20) NOT NULL,
    Quantidade DECIMAL(10, 3) NOT NULL CHECK (Quantidade >= 0),
    PRIMARY KEY (ID_ZonaFisica, Referencia_Artigo),
    FOREIGN KEY (ID_ZonaFisica) REFERENCES ZonaFisica(ID_ZonaFisica),
    FOREIGN KEY (Referencia_Artigo) REFERENCES Artigo(Referencia)
);

-- ==================================================================================
-- 3. TABELAS DE RECURSOS HUMANOS E CLIENTES
-- ==================================================================================

-- Tabela: Funcionários
-- Justificação: Dados detalhados + Supervisor + ZonaGeo + Armazem 
CREATE TABLE Funcionario (
    Numero_Funcionario INT PRIMARY KEY, -- "número de funcionário (único)"
    Nome VARCHAR(100) NOT NULL,
    Cartao_Cidadao VARCHAR(20) NOT NULL UNIQUE,
    NIF VARCHAR(9) NOT NULL UNIQUE,
    Morada VARCHAR(200),
    Salario_Mensal DECIMAL(10, 2) NOT NULL CHECK (Salario_Mensal > 0),
    Data_Nascimento DATE NOT NULL, -- Necessário para RI "idade superior"
    ID_Categoria INT NOT NULL,
    ID_ZonaGeo INT NOT NULL,
    Codigo_Armazem VARCHAR(20) NOT NULL,
    Codigo_Supervisor INT, -- Auto-relacionamento
    
    FOREIGN KEY (ID_Categoria) REFERENCES Categoria(ID_Categoria),
    FOREIGN KEY (ID_ZonaGeo) REFERENCES ZonaGeografica(ID_ZonaGeo),
    FOREIGN KEY (Codigo_Armazem) REFERENCES Armazem(Codigo_Armazem),
    FOREIGN KEY (Codigo_Supervisor) REFERENCES Funcionario(Numero_Funcionario)
);

-- Tabela: Clientes
-- Justificação: Identificados por código, tipo, zona geo 
CREATE TABLE Cliente (
    Codigo_Cliente INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Morada VARCHAR(200) NOT NULL,
    Codigo_Postal VARCHAR(20),
    Telemovel VARCHAR(20),
    NIF VARCHAR(9) NOT NULL UNIQUE,
    Tipo_Cliente VARCHAR(50), -- Ex: 'VIP', 'Pequeno', 'Grande'
    ID_ZonaGeo INT NOT NULL,
    FOREIGN KEY (ID_ZonaGeo) REFERENCES ZonaGeografica(ID_ZonaGeo)
);

-- ==================================================================================
-- 4. TABELAS DE VENDAS E LOGÍSTICA
-- ==================================================================================

-- Tabela: Notas de Encomenda
-- Justificação: Visitados por vendedores, registam artigos 
CREATE TABLE NotaEncomenda (
    Numero_Encomenda INT IDENTITY(1,1) PRIMARY KEY,
    Data_Encomenda DATETIME NOT NULL DEFAULT GETDATE(),
    Estado VARCHAR(20) NOT NULL CHECK (Estado IN ('Pendente', 'Processada', 'Cancelada')), -- 
    Codigo_Cliente INT NOT NULL,
    Numero_Vendedor INT NOT NULL,
    
    FOREIGN KEY (Codigo_Cliente) REFERENCES Cliente(Codigo_Cliente),
    FOREIGN KEY (Numero_Vendedor) REFERENCES Funcionario(Numero_Funcionario)
);

-- Tabela: Linhas de Encomenda (Detalhe)
CREATE TABLE LinhaEncomenda (
    Numero_Encomenda INT NOT NULL,
    Referencia_Artigo VARCHAR(20) NOT NULL,
    Quantidade_Encomendada DECIMAL(10, 3) NOT NULL CHECK (Quantidade_Encomendada > 0),
    
    PRIMARY KEY (Numero_Encomenda, Referencia_Artigo),
    FOREIGN KEY (Numero_Encomenda) REFERENCES NotaEncomenda(Numero_Encomenda),
    FOREIGN KEY (Referencia_Artigo) REFERENCES Artigo(Referencia)
);

-- Tabela: Guias de Saída
-- Justificação: "gerado automaticamente... funcionário responsável... referente a um conjunto de artigos" 
CREATE TABLE GuiaSaida (
    ID_Guia INT IDENTITY(1,1) PRIMARY KEY,
    Data_Hora_Elaboracao DATETIME NOT NULL DEFAULT GETDATE(),
    Numero_Funcionario_Resp INT NOT NULL,
    Numero_Encomenda INT NOT NULL UNIQUE, -- 1 Guia por Encomenda (simplificação)
    
    FOREIGN KEY (Numero_Funcionario_Resp) REFERENCES Funcionario(Numero_Funcionario),
    FOREIGN KEY (Numero_Encomenda) REFERENCES NotaEncomenda(Numero_Encomenda)
);

-- Tabela: Linhas de Guia de Saída (Detalhe Logístico)
-- Justificação: "saber em que zona(s) foi retirado e qual as respetivas quantidades" 
-- Esta tabela é CRÍTICA: Liga a saída ao Stock físico específico (Zona).
CREATE TABLE LinhaGuiaSaida (
    ID_LinhaGuia INT IDENTITY(1,1) PRIMARY KEY,
    ID_Guia INT NOT NULL,
    Referencia_Artigo VARCHAR(20) NOT NULL,
    ID_ZonaFisica_Origem INT NOT NULL, -- De onde saiu o material
    Quantidade_Retirada DECIMAL(10, 3) NOT NULL CHECK (Quantidade_Retirada > 0),
    
    FOREIGN KEY (ID_Guia) REFERENCES GuiaSaida(ID_Guia),
    FOREIGN KEY (Referencia_Artigo) REFERENCES Artigo(Referencia),
    FOREIGN KEY (ID_ZonaFisica_Origem) REFERENCES ZonaFisica(ID_ZonaFisica)
);

-- Tabela: Transportes
-- Justificação: "necessário saber qual a transportadora... data/hora... artigos (via Guia)" 
CREATE TABLE Transporte (
    ID_Transporte INT IDENTITY(1,1) PRIMARY KEY,
    ID_Transportadora INT NOT NULL,
    ID_Guia INT NOT NULL, -- Liga aos artigos transportados e ao cliente de destino
    Data_Hora_Transporte DATETIME NOT NULL,
    Horas_Utilizacao DECIMAL(5, 2) NOT NULL CHECK (Horas_Utilizacao > 0),
    
    FOREIGN KEY (ID_Transportadora) REFERENCES Transportadora(ID_Transportadora),
    FOREIGN KEY (ID_Guia) REFERENCES GuiaSaida(ID_Guia)
);
GO