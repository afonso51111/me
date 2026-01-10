IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'DimCustomers')
BEGIN
CREATE TABLE [dbo].[DimCustomers](
	[CustomerKey] [numeric] IDENTITY(1,1) NOT NULL,
	[CustomerNumber] [numeric](10, 0) NOT NULL,
	[TaxpayerNumber] [varchar](20) NOT NULL,
	[Fax] [varchar](60) NULL,
	[CustomerName] [varchar](100) NOT NULL,
	[CustomerType] [int] NOT NULL,
	[Address] [varchar](200) NOT NULL,
	[City] [varchar](50) NOT NULL,
	[Phone] [varchar](60) NULL,
	[ZipCode] [varchar](20) NOT NULL,
	[Email] [varchar](45) NOT NULL,
	[Location] [varchar](43) NOT NULL,
	[Contact] [varchar](30) NOT NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[ExpiredDate] [datetime] NULL
 CONSTRAINT [PK_DimCustomers] PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [NonClusteredIndex-CustomerNumber] ON [dbo].[DimCustomers]
(
	[CustomerNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)

END