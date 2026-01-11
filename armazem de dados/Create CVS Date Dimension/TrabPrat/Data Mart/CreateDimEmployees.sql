IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'DimEmployees')
BEGIN
CREATE TABLE [dbo].[DimEmployees](
	[EmployeeKey] [numeric] IDENTITY(1,1) NOT NULL,
	[Number] [numeric](6, 0) NOT NULL,
	[Initials] [varchar](3) NOT NULL,
	[Code] [varchar](20) NOT NULL,
	[Forename] [varchar](50) NOT NULL,
	[Surname] [varchar](50) NOT NULL,
	[Group] [varchar](20) NOT NULL,
	[Department] [int] NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[ExpiredDate] [datetime] NULL
 CONSTRAINT [PK_DimEmployees] PRIMARY KEY CLUSTERED 
(
	[EmployeeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [NonClusteredIndex-NumberEmployees] ON [dbo].[DimEmployees]
(
	[Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END

