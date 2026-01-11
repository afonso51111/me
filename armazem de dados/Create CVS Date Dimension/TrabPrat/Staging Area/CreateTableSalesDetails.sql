IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'SalesDetails')
CREATE TABLE [dbo].[SalesDetails](
	[SaleID] [int],
	[SaleLineID] [int],
	[ProductCode] [char](18),
	[Quantity] [numeric](14, 4),
	[VATRate] [numeric](4, 2),
	[UnitPrice] [numeric](19, 6),
	[LineValue] [numeric](19, 6),
)
ELSE
    TRUNCATE TABLE SalesDetails



