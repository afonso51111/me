IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'Customers')
CREATE TABLE [dbo].[Customers](
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
	[Email] [varchar](45),
)
ELSE
    TRUNCATE TABLE Customers

