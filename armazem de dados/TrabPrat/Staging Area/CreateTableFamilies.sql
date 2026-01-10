IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'Families')
CREATE TABLE [dbo].[Families](
	[Code] [int],
	[Name] [varchar](60),
)
ELSE
    TRUNCATE TABLE Families