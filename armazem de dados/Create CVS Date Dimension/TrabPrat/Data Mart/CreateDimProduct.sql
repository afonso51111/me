IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'DimProduct')
BEGIN
CREATE TABLE [dbo].[DimProduct](
	[ProductKey] [numeric] IDENTITY(1,1) NOT NULL,
	[Code] [char](18) NOT NULL,
	[Description] [char](60) NOT NULL,
	[FamilyCode] [int] NOT NULL,
	[Stock] [numeric](13, 3) NOT NULL,
	[UnitPrice] [numeric](19, 6) NOT NULL,
	[OrderPoint] [numeric](10, 3) NOT NULL,
	[MinimunStock] [numeric](13, 3) NOT NULL,
	[StartSellingDate] [date] NOT NULL,
	[Category] [varchar](25) NOT NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[ExpiredDate] [datetime] NULL
 CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED 
(
	[ProductKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [NonClusteredIndex-ProductCode] ON [dbo].[DimProduct]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END