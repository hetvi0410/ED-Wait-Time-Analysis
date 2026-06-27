use er_analytics

-- Load hospitals_clean.csv in Table hospitals

BULK INSERT hospitals
FROM 'D:\DATA ANALYST BOOTCAMP\PROJECTS\New Project - ER Waiting Time Analysis\Cleaned Datasets\hospitals_clean.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
)

-- Load physicians_clean.csv in Table physicians

BULK INSERT physicians
FROM 'D:\DATA ANALYST BOOTCAMP\PROJECTS\New Project - ER Waiting Time Analysis\Cleaned Datasets\physicians_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
)

-- Load nurses_clean.csv in Table nurses

BULK INSERT nurses
FROM 'D:\DATA ANALYST BOOTCAMP\PROJECTS\New Project - ER Waiting Time Analysis\Cleaned Datasets\nurses_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
)

-- Load beds_clean.csv in Table beds

BULK INSERT beds
FROM 'D:\DATA ANALYST BOOTCAMP\PROJECTS\New Project - ER Waiting Time Analysis\Cleaned Datasets\beds_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
)

-- Load er_hourly_metrics_clean.csv in Table er_hourly_metrics

BULK INSERT er_hourly_metrics
FROM 'D:\DATA ANALYST BOOTCAMP\PROJECTS\New Project - ER Waiting Time Analysis\Cleaned Datasets\er_hourly_metrics_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
)

-- Load er_visits_clean.csv in Table er_visits

--BULK INSERT er_visits
--FROM 'D:\DATA ANALYST BOOTCAMP\PROJECTS\New Project - ER Waiting Time Analysis\Cleaned Datasets\er_visits_clean.csv'
--WITH (
--    FIRSTROW = 2,
--    FIELDTERMINATOR = ',',
--    CODEPAGE = '65001',
--    FIELDQUOTE = '"'
--)

BULK INSERT er_visits_stage
FROM 'D:\DATA ANALYST BOOTCAMP\PROJECTS\New Project - ER Waiting Time Analysis\Cleaned Datasets\er_visits_clean.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001'
);















