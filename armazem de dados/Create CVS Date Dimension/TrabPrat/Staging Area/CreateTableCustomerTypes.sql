IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'CustomerTypes')
CREATE TABLE [dbo].[CustomerTypes](
	[Code] [int],
	[Type] [char](20),
)
ELSE
    TRUNCATE TABLE CustomerTypes

