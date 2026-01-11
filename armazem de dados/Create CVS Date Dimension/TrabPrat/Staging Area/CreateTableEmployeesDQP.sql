IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'EmployeesDQP')
CREATE TABLE [dbo].[EmployeesDQP](
	[Number] [numeric](6, 0),
	[Initials] [varchar](3),
	[Code] [varchar](20),
	[Forename] [varchar](50),
	[Surname] [varchar](50),
	[Group] [varchar](20),
	[Department] [int],
	[Email] [varchar](100),
	DQP nvarchar(222)
)
ELSE
    TRUNCATE TABLE EmployeesDQP
