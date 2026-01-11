IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'Departaments')
CREATE TABLE [dbo].[Departaments](
	[Code] [int],
	[Department] [varchar](50),
)
ELSE
    TRUNCATE TABLE Departaments
