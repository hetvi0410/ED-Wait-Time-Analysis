
------------------- STANDARDIZE DATA TYPES -------------------

-------- For er_hourly_metrics table --------

-- Add new temporary column

ALTER TABLE er_hourly_metrics
ADD datetime_hour_dth DATETIME2(0);

-- Convert VARCHAR to DATETIME2

UPDATE er_hourly_metrics
SET datetime_hour_dth = CONVERT(DATETIME2, datetime_hour, 105);

-- Drop old VARCHAR column

ALTER TABLE er_hourly_metrics
DROP COLUMN datetime_hour;

-- Rename new column

EXEC sp_rename 'er_hourly_metrics.datetime_hour_dth', 'datetime_hour', 'COLUMN';



-------- 1. For er_visits table --------

-- Clear main table before loading data

TRUNCATE TABLE er_visits;


-- Clean & Load data from Stage table into Main table
-- (CSV import used VARCHAR for datetime fields in Stage table, Converting then to proper datatypes in Main table)

INSERT INTO er_visits (
    visit_id,
    patient_id,
    age,
    gender,
    arrival_datetime,
    triage_level,
    mode_of_arrival,
    reason_for_visit,
    wait_time_minutes,
    treatment_start_datetime,
    treatment_end_datetime,
    length_of_stay_minutes,
    left_without_being_seen,
    revisit_within_72h,
    physician_id,
    nurse_id,
    bed_id,
    hospital_id,
    discharge_status
)
SELECT 
    CAST(visit_id AS BIGINT),
    patient_id,
    CAST(age AS INT),
    gender,
    CAST(arrival_datetime AS DATETIME2(0)),
    CAST(triage_level AS TINYINT),
    mode_of_arrival,
    reason_for_visit,
    CAST(wait_time_minutes AS INT),
    CAST(treatment_start_datetime AS DATETIME2(0)),
    CAST(treatment_end_datetime AS DATETIME2(0)),
    CAST(length_of_stay_minutes AS INT),
    left_without_being_seen,
    revisit_within_72h,
    physician_id,
    nurse_id,
    bed_id,
    hospital_id,
    discharge_status
FROM er_visits_stage;



------------------- BASIC DATA QUALITY CHECKS -------------------

-- 1.1 Missing values for text columns

select
	SUM(CASE
			WHEN gender IS NULL THEN 1
		END) AS missing_gender,
	SUM(CASE
			WHEN left_without_being_seen IS NULL THEN 1
		END) AS missing_lwbs,
    SUM(CASE
			WHEN revisit_within_72h IS NULL THEN 1
		END) AS revisit_72h
FROM er_visits;

-- Replace NULL with 'Unknown" for varchar columns
-- Gender=6483 NULL, left_without_being_seen=12362 NULL, revisit_within_72h=12297 NULL

ALTER TABLE er_visits
ALTER COLUMN left_without_being_seen VARCHAR(10) NULL;

ALTER TABLE er_visits
ALTER COLUMN revisit_within_72h VARCHAR(10) NULL;

UPDATE er_visits
SET gender = 'Unknown',
    left_without_being_seen = 'Unknown',
    revisit_within_72h = 'Unknown'
WHERE gender IS NULL OR left_without_being_seen IS NULL OR revisit_within_72h IS NULL;


-- 1.2 Missing values for numeric columns

select
	SUM(CASE 
			WHEN age IS NULL THEN 1
		END) AS missing_age,
	SUM(CASE
			WHEN triage_level IS NULL THEN 1
		END) AS missing_triage,
	SUM(CASE
			WHEN wait_time_minutes IS NULL THEN 1
		END) AS missing_wait_time,
    SUM(CASE
			WHEN length_of_stay_minutes IS NULL THEN 1
		END) AS missing_length_of_stay
FROM er_visits;

-- age=1211 NULL will be replaced later



	
-- 2. Invalid triage levels

SELECT * FROM er_visits
WHERE triage_level NOT IN (1,2,3,4,5) OR triage_level IS NULL;


-- 3. Negative or unrealistic wait times

SELECT * FROM er_visits
WHERE wait_time_minutes < 0 OR wait_time_minutes > 1000;


-- 4. Check for datetime conversions

SELECT * FROM er_visits
WHERE arrival_datetime IS NULL
   OR treatment_start_datetime IS NULL
   OR treatment_end_datetime IS NULL;


-- 5. Check for invalid numeric conversions

SELECT * FROM er_visits
WHERE age IS NULL
   OR wait_time_minutes IS NULL
   OR length_of_stay_minutes IS NULL;


-------------------------------
-- Clear er_visits_stage table

TRUNCATE TABLE er_visits_stage;