IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'SalesDQP')
CREATE TABLE [dbo].[SalesDQP](
	[SaleID] [int],
	[SaleDate] [datetime],
	[CustomerNumber] [numeric](10, 0),
	[EmployeeNumber] [numeric](6, 0),
	[PaymentDate] [date],
	[ProductsTotalValue] [numeric](19, 6),
	[VAT] [numeric](19, 6),
	[FinalValue] [numeric](19, 6),
	DQP nvarchar(222)
)
ELSE
    TRUNCATE TABLE SalesDQP

