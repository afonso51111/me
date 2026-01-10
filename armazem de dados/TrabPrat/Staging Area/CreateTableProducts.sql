IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'Products')
CREATE TABLE [dbo].[Products](
	[Code] [char](18),
	[Description] [char](60),
	[FamilyCode] [int],
	[Stock] [numeric](13, 3),
	[UnitPrice] [numeric](19, 6),
	[OrderPoint] [numeric](10, 3),
	[MinimunStock] [numeric](13, 3),
	[StartSellingDate] [date],
	[Category] [varchar](25),
)
ELSE
    TRUNCATE TABLE Products

