IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'FactSales')
    CREATE TABLE [dbo].[FactSales](
        [DateKey] [int] NOT NULL,
        [CustomerKey] [numeric] NOT NULL,
        [ProductKey] [numeric] NOT NULL,
        [EmployeeKey] [numeric] NOT NULL,
        [TransactionID] [char](9) NOT NULL,
        [Quantity] [int] NULL,
        [Amount] [money] NULL,
        CONSTRAINT [FK_FactSale_DimDate] FOREIGN KEY([DateKey]) REFERENCES [dbo].[DimDate] ([DateKey]),
        CONSTRAINT [FK_FactSale_DimCustomer] FOREIGN KEY([CustomerKey]) REFERENCES [dbo].[DimCustomers] ([CustomerKey]),
        CONSTRAINT [FK_FactSale_DimProduct] FOREIGN KEY([ProductKey]) REFERENCES [dbo].[DimProduct] ([ProductKey]),
        CONSTRAINT [FK_FactSale_DimEmployee] FOREIGN KEY([EmployeeKey]) REFERENCES [dbo].[DimEmployees] ([EmployeeKey])
    ) ON [PRIMARY]