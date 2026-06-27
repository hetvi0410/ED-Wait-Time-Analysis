
------------------- ANALYSIS QUERIES -------------------

---------- 1. CORE ER OPERATIONAL KPIs ----------


-- Average ER wait time by hospital

SELECT hospital_id, AVG(wait_time_minutes) AS avg_wait_time
FROM er_visits
GROUP BY hospital_id
ORDER BY avg_wait_time DESC;


-- LWBS (Left Without Being Seen) rate

SELECT 
	hospital_id, 
	COUNT(*) AS total_visits,
	SUM(CASE WHEN left_without_being_seen = 'Yes' THEN 1 END) AS lwbs_count,
	100 * SUM(CASE WHEN left_without_being_seen = 'Yes' THEN 1 END) / COUNT(*) AS lwbs_rate
FROM er_visits
GROUP BY hospital_id
ORDER BY lwbs_rate DESC;


-- Revisit rate within 72 hours

SELECT  
    hospital_id,
    COUNT(*) AS total_visits,
    SUM(CASE WHEN revisit_within_72h = 'Yes' THEN 1 END) AS revisit_count,
    100 * SUM(CASE WHEN revisit_within_72h = 'Yes' THEN 1 END) / COUNT(*) AS revisit_rate
FROM er_visits
GROUP BY hospital_id
ORDER BY revisit_rate DESC;


---------- 2. TIME‑BASED & PATTERN ANALYSIS ----------

-- Visits per hour

SELECT
	DATEPART(HOUR, arrival_datetime) AS arrival_hour,
	COUNT(*) AS visit_count
FROM er_visits
GROUP BY DATEPART(HOUR, arrival_datetime)
ORDER BY arrival_hour;


-- Average wait time by hour

SELECT
	DATEPART(HOUR, arrival_datetime) AS arrival_hour,
	AVG(wait_time_minutes) AS avg_wait_time
FROM er_visits
GROUP BY DATEPART(HOUR, arrival_datetime)
ORDER BY arrival_hour;


-- Peak ER hours

SELECT TOP 5
    DATEPART(HOUR, arrival_datetime) AS hour,
    COUNT(*) AS visit_count
FROM er_visits
GROUP BY DATEPART(HOUR, arrival_datetime)
ORDER BY visit_count DESC;


---------- 3. TRIAGE & ARRIVAL MODE ANALYSIS ----------

-- Average wait time by triage level

SELECT 
    triage_level,
    COUNT(*) AS total_visits,
    AVG(wait_time_minutes) AS avg_wait_time
FROM er_visits
GROUP BY triage_level
ORDER BY triage_level;


-- Average length of stay by triage level

SELECT
  triage_level,
  COUNT(*) AS total_visits,
  AVG(length_of_stay_minutes) AS avg_length_of_stay
FROM er_visits
GROUP BY triage_level
ORDER BY triage_level;


-- Wait time by mode of arrival

SELECT 
    mode_of_arrival,
    COUNT(*) AS total_visits,
    AVG(wait_time_minutes) AS avg_wait_time
FROM er_visits
GROUP BY mode_of_arrival
ORDER BY avg_wait_time DESC;


---------- 4. WINDOW FUNCTIONS (ADVANCED SQL) ----------

-- Rank hospitals by average wait time

SELECT 
    hospital_id,
    AVG(wait_time_minutes) AS avg_wait_time,
    RANK() OVER (ORDER BY AVG(wait_time_minutes) DESC) AS wait_rank
FROM er_visits
GROUP BY hospital_id;


-- CTE - Rolling 7‑day average wait time

WITH daily AS (
    SELECT  
        hospital_id,
        CAST(arrival_datetime AS DATE) AS visit_date,
        AVG(wait_time_minutes) AS avg_wait
    FROM er_visits
    GROUP BY hospital_id, CAST(arrival_datetime AS DATE)
)
SELECT  
    hospital_id,
    visit_date,
    avg_wait,
    AVG(avg_wait) OVER (
        PARTITION BY hospital_id
        ORDER BY visit_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7_day_avg
FROM daily
ORDER BY hospital_id, visit_date;


---------- 5. JOIN WITH HOURLY METRICS (MULTI‑TABLE ANALYSIS) ----------

-- Combine visits with hourly occupancy

SELECT 
    v.hospital_id,
    v.arrival_datetime,
    v.wait_time_minutes,
    m.er_occupancy,
    m.staffing_level
FROM er_visits v 
LEFT JOIN er_hourly_metrics m
    ON v.hospital_id = m.hospital_id
    AND DATEPART(HOUR, v.arrival_datetime) = DATEPART(HOUR, m.datetime_hour)
    AND CAST(v.arrival_datetime AS DATE) = CAST(m.datetime_hour AS DATE);



---------- 6. ADVANCED KPI (INNER JOIN) ----------

-- Wait time Vs Occupancy 

SELECT 
    m.hospital_id,
    m.er_occupancy,
    AVG(v.wait_time_minutes) AS avg_wait_time
FROM er_hourly_metrics m
JOIN er_visits v
    ON m.hospital_id = v.hospital_id
    AND DATEPART(HOUR, v.arrival_datetime) = DATEPART(HOUR, m.datetime_hour)
    AND CAST(v.arrival_datetime AS DATE) = CAST(m.datetime_hour AS DATE)
GROUP BY m.hospital_id, m.er_occupancy
ORDER BY m.er_occupancy;


---------- 7. PATIENT FLOW ANALYSIS ----------

-- Time from arrival to treatment start

SELECT
    visit_id,
    DATEDIFF(MINUTE, arrival_datetime, treatment_start_datetime) AS arrival_to_treatment
FROM er_visits
ORDER BY arrival_to_treatment DESC;


---------- 8. Triage‑Level Deep Dive ----------

-- LWBS rate by triage level

-- (NULLIF(...,0) converts the denominator to NULL when it is 0, preventing a divide‑by‑zero error. 
-- If there are no non‑NULL LWBS values for a triage level, the result becomes NULL instead of causing an error.)
-- If you prefer to show 0% instead of NULL when denominator is zero, wrap the expression with COALESCE(...,0).

SELECT
    triage_level,
    COUNT(*) AS total_visits,
    SUM(CASE WHEN left_without_being_seen = 'Yes' THEN 1 ELSE 0 END) AS lwbs_count,
    100 * SUM(CASE WHEN left_without_being_seen = 'Yes' THEN 1 ELSE 0 END)
     / NULLIF(SUM(CASE WHEN left_without_being_seen IS NOT NULL THEN 1 ELSE 0 END),0) AS lwbs_rate_percent
FROM er_visits
GROUP BY triage_level
ORDER BY lwbs_rate_percent DESC;


-- Volume of visits by triage level (overall)

SELECT
  triage_level,
  COUNT(*) AS visit_count
FROM er_visits
GROUP BY triage_level
ORDER BY visit_count DESC;

-- Volume of visits by triage level (by hospital)

SELECT
  hospital_id,
  triage_level,
  COUNT(*) AS visit_count
FROM er_visits
GROUP BY hospital_id, triage_level
ORDER BY hospital_id, visit_count DESC;


-- Percentage of meeting target treatment time by triage level
-- (Assumeing target thresholds per triage level)

WITH targets AS (
  SELECT 1 AS triage_level, 15 AS target_minutes UNION ALL
  SELECT 2, 30 UNION ALL
  SELECT 3, 60 UNION ALL
  SELECT 4, 120 UNION ALL
  SELECT 5, 240
)
SELECT
  e.triage_level,
  COUNT(*) AS total_visits,
  SUM(CASE WHEN DATEDIFF(MINUTE, e.arrival_datetime, e.treatment_start_datetime) <= t.target_minutes THEN 1 ELSE 0 END) AS met_target_count,
  100.0 * SUM(CASE WHEN DATEDIFF(MINUTE, e.arrival_datetime, e.treatment_start_datetime) <= t.target_minutes THEN 1 ELSE 0 END)
    / NULLIF(COUNT(*),0) AS pct_meeting_target
FROM er_visits e
JOIN targets t ON e.triage_level = t.triage_level
GROUP BY e.triage_level
ORDER BY e.triage_level;


-- Compare Level 1–2 vs Level 4–5 wait times (common finding)


WITH visits AS (
    SELECT *,
    CASE WHEN triage_level IN (1,2) THEN 'Level 1-2'
         WHEN triage_level IN (4,5) THEN 'Level 4-5'
         ELSE 'Other' END AS triage_group
FROM er_visits
)
SELECT triage_group,
       COUNT(*) AS total_visits,
       AVG(wait_time_minutes) AS avg_wait_time
FROM visits
GROUP BY triage_group
ORDER BY avg_wait_time;



