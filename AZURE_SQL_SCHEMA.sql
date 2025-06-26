/****** Object:  Table [dbo].[clients]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clients](
	[client_id] [int] IDENTITY(1,1) NOT NULL,
	[display_name] [nvarchar](255) NOT NULL,
	[full_name] [nvarchar](255) NULL,
	[ima_signed_date] [nvarchar](50) NULL,
	[onedrive_folder_path] [nvarchar](500) NULL,
	[valid_from] [datetime] NULL,
	[valid_to] [datetime] NULL,
 CONSTRAINT [PK_clients] PRIMARY KEY CLUSTERED 
(
	[client_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[client_metrics]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[client_metrics](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[client_id] [int] NOT NULL,
	[last_payment_date] [nvarchar](50) NULL,
	[last_payment_amount] [float] NULL,
	[last_payment_quarter] [int] NULL,
	[last_payment_year] [int] NULL,
	[total_ytd_payments] [float] NULL,
	[avg_quarterly_payment] [float] NULL,
	[last_recorded_assets] [float] NULL,
	[last_updated] [nvarchar](50) NULL,
	[next_payment_due] [nvarchar](50) NULL,
 CONSTRAINT [PK_client_metrics] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_client_metrics_client_id] UNIQUE NONCLUSTERED 
(
	[client_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[contracts]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contracts](
	[contract_id] [int] IDENTITY(1,1) NOT NULL,
	[client_id] [int] NOT NULL,
	[contract_number] [nvarchar](100) NULL,
	[provider_name] [nvarchar](255) NULL,
	[contract_start_date] [nvarchar](50) NULL,
	[fee_type] [nvarchar](50) NULL,
	[percent_rate] [float] NULL,
	[flat_rate] [float] NULL,
	[payment_schedule] [nvarchar](50) NULL,
	[num_people] [int] NULL,
	[notes] [nvarchar](max) NULL,
	[valid_from] [datetime] NULL,
	[valid_to] [datetime] NULL,
 CONSTRAINT [PK_contracts] PRIMARY KEY CLUSTERED 
(
	[contract_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[payments]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payments](
	[payment_id] [int] IDENTITY(1,1) NOT NULL,
	[contract_id] [int] NOT NULL,
	[client_id] [int] NOT NULL,
	[received_date] [nvarchar](50) NULL,
	[total_assets] [float] NULL,
	[expected_fee] [float] NULL,
	[actual_fee] [float] NULL,
	[method] [nvarchar](50) NULL,
	[notes] [nvarchar](max) NULL,
	[valid_from] [datetime] NULL,
	[valid_to] [datetime] NULL,
	[applied_start_month] [int] NULL,
	[applied_start_month_year] [int] NULL,
	[applied_end_month] [int] NULL,
	[applied_end_month_year] [int] NULL,
	[applied_start_quarter] [int] NULL,
	[applied_start_quarter_year] [int] NULL,
	[applied_end_quarter] [int] NULL,
	[applied_end_quarter_year] [int] NULL,
 CONSTRAINT [PK_payments] PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[client_payment_status]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[client_payment_status] AS
SELECT
    c.client_id,
    c.display_name,
    ct.payment_schedule,
    ct.fee_type,
    ct.flat_rate,
    ct.percent_rate,
    
    -- Last payment information
    cm.last_payment_date,
    cm.last_payment_amount,
    latest.applied_end_month,
    latest.applied_end_month_year,
    latest.applied_end_quarter,
    latest.applied_end_quarter_year,
    
    -- Calculate current period (based on today's date - 1 period)
    CASE 
        WHEN ct.payment_schedule = 'monthly' THEN 
            CASE 
                WHEN MONTH(GETDATE()) = 1 THEN 12 
                ELSE MONTH(GETDATE()) - 1 
            END
        ELSE NULL
    END AS current_month,
    
    CASE 
        WHEN ct.payment_schedule = 'monthly' THEN 
            CASE 
                WHEN MONTH(GETDATE()) = 1 THEN YEAR(GETDATE()) - 1
                ELSE YEAR(GETDATE())
            END
        ELSE NULL
    END AS current_month_year,
    
    CASE 
        WHEN ct.payment_schedule = 'quarterly' THEN 
            CASE 
                WHEN DATEPART(QUARTER, GETDATE()) = 1 THEN 4
                ELSE DATEPART(QUARTER, GETDATE()) - 1
            END
        ELSE NULL
    END AS current_quarter,
    
    CASE 
        WHEN ct.payment_schedule = 'quarterly' THEN 
            CASE 
                WHEN DATEPART(QUARTER, GETDATE()) = 1 THEN YEAR(GETDATE()) - 1
                ELSE YEAR(GETDATE())
            END
        ELSE NULL
    END AS current_quarter_year,
    
    -- Latest assets for calculating expected fee
    cm.last_recorded_assets,
    
    -- Calculate expected fee based on fee_type
    CASE
        WHEN ct.fee_type = 'flat' THEN ct.flat_rate
        WHEN ct.fee_type = 'percentage' AND cm.last_recorded_assets IS NOT NULL THEN 
            ROUND(cm.last_recorded_assets * (ct.percent_rate / 100.0), 2)
        ELSE NULL
    END AS expected_fee,
    
    -- Determine payment status (Due/Paid)
    CASE
        WHEN ct.payment_schedule = 'monthly' AND (
            latest.applied_end_month_year IS NULL OR
            latest.applied_end_month_year < CASE 
                WHEN MONTH(GETDATE()) = 1 THEN YEAR(GETDATE()) - 1
                ELSE YEAR(GETDATE())
            END OR
            (latest.applied_end_month_year = CASE 
                WHEN MONTH(GETDATE()) = 1 THEN YEAR(GETDATE()) - 1
                ELSE YEAR(GETDATE())
            END AND latest.applied_end_month < CASE 
                WHEN MONTH(GETDATE()) = 1 THEN 12 
                ELSE MONTH(GETDATE()) - 1 
            END)
        ) THEN 'Due'
        WHEN ct.payment_schedule = 'quarterly' AND (
            latest.applied_end_quarter_year IS NULL OR
            latest.applied_end_quarter_year < CASE 
                WHEN DATEPART(QUARTER, GETDATE()) = 1 THEN YEAR(GETDATE()) - 1
                ELSE YEAR(GETDATE())
            END OR
            (latest.applied_end_quarter_year = CASE 
                WHEN DATEPART(QUARTER, GETDATE()) = 1 THEN YEAR(GETDATE()) - 1
                ELSE YEAR(GETDATE())
            END AND latest.applied_end_quarter < CASE 
                WHEN DATEPART(QUARTER, GETDATE()) = 1 THEN 4
                ELSE DATEPART(QUARTER, GETDATE()) - 1
            END)
        ) THEN 'Due'
        ELSE 'Paid'
    END AS payment_status
FROM 
    clients c
JOIN 
    contracts ct ON c.client_id = ct.client_id AND ct.valid_to IS NULL
LEFT JOIN 
    client_metrics cm ON c.client_id = cm.client_id
LEFT JOIN (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY received_date DESC) as rn
        FROM payments
        WHERE valid_to IS NULL
    ) AS numbered
    WHERE rn = 1
) latest ON c.client_id = latest.client_id
WHERE 
    c.valid_to IS NULL;
GO
/****** Object:  Table [dbo].[client_files]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[client_files](
	[file_id] [int] IDENTITY(1,1) NOT NULL,
	[client_id] [int] NOT NULL,
	[file_name] [nvarchar](255) NOT NULL,
	[onedrive_path] [nvarchar](500) NOT NULL,
	[uploaded_at] [datetime] NULL,
 CONSTRAINT [PK_client_files] PRIMARY KEY CLUSTERED 
(
	[file_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[payment_files]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payment_files](
	[payment_id] [int] NOT NULL,
	[file_id] [int] NOT NULL,
	[linked_at] [datetime] NULL,
 CONSTRAINT [PK_payment_files] PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC,
	[file_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[payment_file_view]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[payment_file_view] AS
SELECT 
    p.payment_id,
    p.client_id,
    p.contract_id,
    p.received_date,
    p.actual_fee,
    CASE WHEN cf.file_id IS NOT NULL THEN 1 ELSE 0 END AS has_file,
    cf.file_id,
    cf.file_name,
    cf.onedrive_path
FROM 
    payments p
LEFT JOIN 
    payment_files pf ON p.payment_id = pf.payment_id
LEFT JOIN 
    client_files cf ON pf.file_id = cf.file_id;
GO
/****** Object:  Table [dbo].[contacts]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contacts](
	[contact_id] [int] IDENTITY(1,1) NOT NULL,
	[client_id] [int] NOT NULL,
	[contact_type] [nvarchar](50) NOT NULL,
	[contact_name] [nvarchar](255) NULL,
	[phone] [nvarchar](50) NULL,
	[email] [nvarchar](255) NULL,
	[fax] [nvarchar](50) NULL,
	[physical_address] [nvarchar](500) NULL,
	[mailing_address] [nvarchar](500) NULL,
	[valid_from] [datetime] NULL,
	[valid_to] [datetime] NULL,
 CONSTRAINT [PK_contacts] PRIMARY KEY CLUSTERED 
(
	[contact_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[quarterly_summaries]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[quarterly_summaries](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[client_id] [int] NOT NULL,
	[year] [int] NOT NULL,
	[quarter] [int] NOT NULL,
	[total_payments] [float] NULL,
	[total_assets] [float] NULL,
	[payment_count] [int] NULL,
	[avg_payment] [float] NULL,
	[expected_total] [float] NULL,
	[last_updated] [nvarchar](50) NULL,
 CONSTRAINT [PK_quarterly_summaries] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_quarterly_summaries] UNIQUE NONCLUSTERED 
(
	[client_id] ASC,
	[year] ASC,
	[quarter] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[yearly_summaries]    Script Date: 6/26/2025 12:23:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[yearly_summaries](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[client_id] [int] NOT NULL,
	[year] [int] NOT NULL,
	[total_payments] [float] NULL,
	[total_assets] [float] NULL,
	[payment_count] [int] NULL,
	[avg_payment] [float] NULL,
	[yoy_growth] [float] NULL,
	[last_updated] [nvarchar](50) NULL,
 CONSTRAINT [PK_yearly_summaries] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_yearly_summaries] UNIQUE NONCLUSTERED 
(
	[client_id] ASC,
	[year] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_client_metrics_lookup]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_client_metrics_lookup] ON [dbo].[client_metrics]
(
	[client_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_contacts_client_id]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_contacts_client_id] ON [dbo].[contacts]
(
	[client_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_contacts_type]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_contacts_type] ON [dbo].[contacts]
(
	[client_id] ASC,
	[contact_type] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_contracts_client_id]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_contracts_client_id] ON [dbo].[contracts]
(
	[client_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_contracts_provider]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_contracts_provider] ON [dbo].[contracts]
(
	[provider_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_payments_applied_months]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_payments_applied_months] ON [dbo].[payments]
(
	[client_id] ASC,
	[applied_start_month_year] ASC,
	[applied_start_month] ASC,
	[applied_end_month_year] ASC,
	[applied_end_month] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_payments_client_id]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_payments_client_id] ON [dbo].[payments]
(
	[client_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_payments_contract_id]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_payments_contract_id] ON [dbo].[payments]
(
	[contract_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_payments_date]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_payments_date] ON [dbo].[payments]
(
	[client_id] ASC,
	[received_date] DESC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_quarterly_lookup]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_quarterly_lookup] ON [dbo].[quarterly_summaries]
(
	[client_id] ASC,
	[year] ASC,
	[quarter] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_yearly_lookup]    Script Date: 6/26/2025 12:23:40 AM ******/
CREATE NONCLUSTERED INDEX [idx_yearly_lookup] ON [dbo].[yearly_summaries]
(
	[client_id] ASC,
	[year] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[client_files] ADD  DEFAULT (getdate()) FOR [uploaded_at]
GO
ALTER TABLE [dbo].[clients] ADD  DEFAULT (getdate()) FOR [valid_from]
GO
ALTER TABLE [dbo].[contacts] ADD  DEFAULT (getdate()) FOR [valid_from]
GO
ALTER TABLE [dbo].[contracts] ADD  DEFAULT (getdate()) FOR [valid_from]
GO
ALTER TABLE [dbo].[payment_files] ADD  DEFAULT (getdate()) FOR [linked_at]
GO
ALTER TABLE [dbo].[payments] ADD  DEFAULT (getdate()) FOR [valid_from]
GO
ALTER TABLE [dbo].[client_files]  WITH CHECK ADD  CONSTRAINT [FK_client_files_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([client_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[client_files] CHECK CONSTRAINT [FK_client_files_clients]
GO
ALTER TABLE [dbo].[client_metrics]  WITH CHECK ADD  CONSTRAINT [FK_client_metrics_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([client_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[client_metrics] CHECK CONSTRAINT [FK_client_metrics_clients]
GO
ALTER TABLE [dbo].[contacts]  WITH CHECK ADD  CONSTRAINT [FK_contacts_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([client_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contacts] CHECK CONSTRAINT [FK_contacts_clients]
GO
ALTER TABLE [dbo].[contracts]  WITH CHECK ADD  CONSTRAINT [FK_contracts_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([client_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contracts] CHECK CONSTRAINT [FK_contracts_clients]
GO
ALTER TABLE [dbo].[payment_files]  WITH CHECK ADD  CONSTRAINT [FK_payment_files_client_files] FOREIGN KEY([file_id])
REFERENCES [dbo].[client_files] ([file_id])
GO
ALTER TABLE [dbo].[payment_files] CHECK CONSTRAINT [FK_payment_files_client_files]
GO
ALTER TABLE [dbo].[payment_files]  WITH CHECK ADD  CONSTRAINT [FK_payment_files_payments] FOREIGN KEY([payment_id])
REFERENCES [dbo].[payments] ([payment_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[payment_files] CHECK CONSTRAINT [FK_payment_files_payments]
GO
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [FK_payments_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([client_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [FK_payments_clients]
GO
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [FK_payments_contracts] FOREIGN KEY([contract_id])
REFERENCES [dbo].[contracts] ([contract_id])
GO
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [FK_payments_contracts]
GO
ALTER TABLE [dbo].[quarterly_summaries]  WITH CHECK ADD  CONSTRAINT [FK_quarterly_summaries_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([client_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[quarterly_summaries] CHECK CONSTRAINT [FK_quarterly_summaries_clients]
GO
ALTER TABLE [dbo].[yearly_summaries]  WITH CHECK ADD  CONSTRAINT [FK_yearly_summaries_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([client_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[yearly_summaries] CHECK CONSTRAINT [FK_yearly_summaries_clients]
GO
ALTER DATABASE [HohimerPro-401k] SET  READ_WRITE 
GO
