

create database er_analytics;
use er_analytics

-- 1. Create Hospitals Table ------------

create table hospitals (
	hospital_id VARCHAR(5) PRIMARY KEY,
	hospital_name VARCHAR(100),
	city VARCHAR(50),
    province VARCHAR(10),
    hospital_type VARCHAR(50)
)

-- 2. Create Physicians Table ------------

create table physicians (
	physician_id VARCHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	specialty VARCHAR(50),
	years_experience INT
)

-- 3. Create Nurses Table ------------

create table nurses (
	nurse_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100),
    years_experience INT
)

-- 4. Create Beds Table ------------

create table beds (
	bed_id VARCHAR(10) PRIMARY KEY,
    bed_type VARCHAR(50),
    department VARCHAR(20)
)

-- 5. Create ER Hourly Metrics Table ------------

create table er_hourly_metrics (
	hospital_id VARCHAR(5),
	datetime_hour VARCHAR(50),
	er_occupancy INT,
	staffing_level INT,
	avg_wait_time_last_hour INT,
	patients_left_without_being_seen_last_hour INT,
	FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
)

-- 6. Create ER Visits Table ((Main Fact Table) ------------

create table er_visits (
	visit_id BIGINT PRIMARY KEY,
	patient_id VARCHAR(20),
    age INT,
    gender VARCHAR(10),
    arrival_datetime VARCHAR(100),
    triage_level TINYINT,
    mode_of_arrival VARCHAR(20),
    reason_for_visit VARCHAR(100),
    wait_time_minutes INT,
    treatment_start_datetime VARCHAR(100),
    treatment_end_datetime VARCHAR(100),
    length_of_stay_minutes INT,
    left_without_being_seen VARCHAR(3),
    revisit_within_72h VARCHAR(3),
    physician_id VARCHAR(10),
    nurse_id VARCHAR(10),
    bed_id VARCHAR(10),
    hospital_id VARCHAR(5),
    discharge_status VARCHAR(20),
    FOREIGN KEY (physician_id) REFERENCES physicians(physician_id),
    FOREIGN KEY (nurse_id) REFERENCES nurses(nurse_id),
    FOREIGN KEY (bed_id) REFERENCES beds(bed_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
);


-- Create er_visits_stage table with varchar datatype for all the columns to load the csv

CREATE TABLE er_visits_stage (
    visit_id VARCHAR(50),
    patient_id VARCHAR(50),
    age VARCHAR(50),
    gender VARCHAR(50),
    arrival_datetime VARCHAR(100),
    triage_level VARCHAR(50),
    mode_of_arrival VARCHAR(50),
    reason_for_visit VARCHAR(255),
    wait_time_minutes VARCHAR(50),
    treatment_start_datetime VARCHAR(100),
    treatment_end_datetime VARCHAR(100),
    length_of_stay_minutes VARCHAR(50),
    left_without_being_seen VARCHAR(10),
    revisit_within_72h VARCHAR(10),
    physician_id VARCHAR(50),
    nurse_id VARCHAR(50),
    bed_id VARCHAR(50),
    hospital_id VARCHAR(50),
    discharge_status VARCHAR(50)
);
