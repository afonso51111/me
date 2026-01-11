IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'Sales')
CREATE TABLE [dbo].[Sales](
	[SaleID] [int],
	[SaleDate] [datetime],
	[CustomerNumber] [numeric](10, 0),
	[EmployeeNumber] [numeric](6, 0),
	[PaymentDate] [date],
	[ProductsTotalValue] [numeric](19, 6),
	[VAT] [numeric](19, 6),
	[FinalValue] [numeric](19, 6),
)
ELSE
    TRUNCATE TABLE Sales

