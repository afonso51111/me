IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'CustomersDQP')
CREATE TABLE [dbo].[CustomersDQP](
	[Name] [varchar](55),
	[Number] [numeric](10, 0),
	[TaxpayerNumber] [varchar](20),
	[Fax] [varchar](60),
	[Phone] [varchar](60),
	[Contact] [varchar](30),
	[Address] [varchar](55),
	[ZipCode] [varchar](10),
	[City] [varchar](33),
	[Location] [varchar](43),
	[CustomerType] [int],
	[Email] [varchar](55),
	DQP nvarchar(222)
)
ELSE
    TRUNCATE TABLE CustomersDQP

