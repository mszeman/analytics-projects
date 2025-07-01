CREATE DATABASE IF NOT EXISTS OlympicSchema;
USE OlympicSchema;

-- Remove existing tables if they exist to avoid errors during table creation.
DROP TABLE IF EXISTS Participants;
DROP TABLE IF EXISTS Olympians;
DROP TABLE IF EXISTS Athletes;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Medals;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Sports;
DROP TABLE IF EXISTS Games;

-- Dimension Table: Sports
CREATE TABLE Sports (
    sport_ID VARCHAR(10), -- Unique identifier for each sport.
    sport VARCHAR(50),      -- name of the sport
    PRIMARY KEY (sport_ID)
);

-- Dimension Table: Events
CREATE TABLE Events (
    event_ID VARCHAR(10),         -- Unique identifier for each event
    event VARCHAR(100),  -- title of each event
    sport_ID VARCHAR(10),        -- which sport the event was in
    FOREIGN KEY (sport_ID) REFERENCES Sports (sport_ID),
    PRIMARY KEY (event_ID)
);

-- Dimension Table: Medals
CREATE TABLE Medals (
    medal_ID VARCHAR(10), -- Unique identifier for each Games.
    medal VARCHAR(6),      -- name of the medal earned
    PRIMARY KEY (medal_ID)
);

-- Dimension Table: Teams
CREATE TABLE Teams (
    team_ID VARCHAR(10), -- Unique identifier for each team.
    NOC VARCHAR(3),      -- Olympic Team Code
    team VARCHAR(50),    -- name of team
    PRIMARY KEY (team_ID)
);

-- Dimension Table: Athletes
CREATE TABLE Athletes (
    athlete_ID VARCHAR(10), -- Unique identifier for each athlete.
    name VARCHAR(200),      -- name of the athlete
    gender VARCHAR(1),    -- gender of the athlete (M or F)
    height INT,      -- height of the athlete
    PRIMARY KEY (athlete_ID)
);

-- Dimension Table: Olympians
CREATE TABLE Olympians (
    olympian_ID VARCHAR(10), -- Unique identifier for each Games.
    athlete_ID VARCHAR(10),      -- foreign key to athlete
    age INT,    -- age of athlete at time of games
    weight INT, 
    team_ID VARCHAR(10), 
    sport_ID VARCHAR(10),
    FOREIGN KEY (athlete_ID) REFERENCES Athletes(athlete_ID),      -- Establishes a foreign key relationship with Athletes.
    FOREIGN KEY (team_ID) REFERENCES Teams(team_ID), -- Establishes a foreign key relationship with Teams.
    FOREIGN KEY (sport_ID) REFERENCES Sports (sport_ID),
    PRIMARY KEY (olympian_ID)
);

-- Dimension Table: Games
CREATE TABLE Games (
    olympics_ID VARCHAR(10), -- Unique identifier for each Games.
    year INT,      -- year the games occurred
    season VARCHAR(50),    -- winter or summer
    city VARCHAR(50),      -- city where the olympics occurred
    PRIMARY KEY (olympics_ID)
);

-- Fact Table: Participants
-- This table associates the athletes with the medals they won and at what games and what event they competed
CREATE TABLE Participants (
    event_participant_ID VARCHAR(10), 
    olympian_ID VARCHAR(10),                   
    olympics_ID VARCHAR(10), 
    event_ID VARCHAR(10),             
    medal_ID VARCHAR(10),    
    FOREIGN KEY (olympian_ID) REFERENCES Olympians(olympian_ID),      
    FOREIGN KEY (olympics_ID) REFERENCES Games(olympics_ID), 
    FOREIGN KEY (event_ID) REFERENCES Events (event_ID),
    FOREIGN KEY (medal_ID) REFERENCES Medals(medal_ID),
    PRIMARY KEY (event_participant_ID)
);

-- load tables here --


-- check tables
select * from games;
select * from medals;
select * from sports;
select * from events;
select * from teams;
select * from athletes;
select * from olympians;
select * from participants;
select count(*) from participants;

-- update 999s to nulls for tables: athletes (height), olympians (weight) --
-- when height, weight, age data was not available, 999 was entered, skewing the data. replace these with NULL -- 
SET SQL_SAFE_UPDATES = 0;

UPDATE athletes
SET height = NULL
WHERE height = 999;

UPDATE olympians
SET weight = NULL
WHERE weight = 999;

UPDATE olympians
SET age = NULL
WHERE age = 999;

SET SQL_SAFE_UPDATES = 1;

-- Querries --

-- Topic: Gender parity in Olympic games through history
drop table if exists overall;
drop table if exists summer_table;
drop table if exists winter_table;

-- #1 percentage of male/female participants per year for each olympics 
-- Calculate percentage of male and female participants for each Olympic year
CREATE TABLE overall AS
SELECT
    g.year AS Olympic_Year,
    COUNT(CASE WHEN a.gender = 'M' THEN 1 END) * 100.0 / COUNT(*) AS Percent_Male,
    COUNT(CASE WHEN a.gender = 'F' THEN 1 END) * 100.0 / COUNT(*) AS Percent_Female
FROM
    games g
    JOIN participants p ON g.olympics_ID = p.olympics_ID
    JOIN olympians o ON p.olympian_ID = o.olympian_ID
    JOIN athletes a ON o.athlete_ID = a.athlete_ID
GROUP BY
    g.year
ORDER BY
    g.year;
    
-- #2 Calculate percentage of male and female participants for each summer Olympic year
CREATE TABLE summer_table AS
SELECT
    g.year AS Olympic_Year,
    COUNT(CASE WHEN a.gender = 'M' THEN 1 END) * 100.0 / COUNT(*) AS Percent_Male,
    COUNT(CASE WHEN a.gender = 'F' THEN 1 END) * 100.0 / COUNT(*) AS Percent_Female
FROM
    games g
    JOIN participants p ON g.olympics_ID = p.olympics_ID
    JOIN olympians o ON p.olympian_ID = o.olympian_ID
    JOIN athletes a ON o.athlete_ID = a.athlete_ID
WHERE
    g.season = 'summer'
GROUP BY
    g.year
ORDER BY
    g.year;

-- #3 Calculate percentage of male and female participants for each winter Olympic year
CREATE TABLE winter_table AS
SELECT
    g.year AS Olympic_Year,
    COUNT(CASE WHEN a.gender = 'M' THEN 1 END) * 100.0 / COUNT(*) AS Percent_Male,
    COUNT(CASE WHEN a.gender = 'F' THEN 1 END) * 100.0 / COUNT(*) AS Percent_Female
FROM
    games g
    JOIN participants p ON g.olympics_ID = p.olympics_ID
    JOIN olympians o ON p.olympian_ID = o.olympian_ID
    JOIN athletes a ON o.athlete_ID = a.athlete_ID
WHERE
    g.season = 'winter'
GROUP BY
    g.year
ORDER BY
    g.year;
    
select * from summer_table;
select * from winter_table;

-- #4 which countries had the greatest percentage of female participants over time? which countries were over 50%?
-- Calculate the average percentage of female participants for each country, filter to >= 50%, 
-- 		and also include the total number of female Olympians for scale
drop table if exists top_countries;
CREATE TABLE top_countries AS
WITH YearlyGenderPercentages AS (
    SELECT
        t.team AS Country,
        COUNT(CASE WHEN a.gender = 'F' THEN 1 END) AS Total_Female,
        COUNT(*) AS Total_Participants
    FROM
        games g
        JOIN participants p ON g.olympics_ID = p.olympics_ID
        JOIN olympians o ON p.olympian_ID = o.olympian_ID
        JOIN athletes a ON o.athlete_ID = a.athlete_ID
        JOIN teams t ON o.team_ID = t.team_ID
    GROUP BY
        t.team
),
CountryPercentages AS (
    SELECT
        Country,
        (Total_Female * 100.0 / Total_Participants) AS Percent_Female,
        Total_Female
    FROM
        YearlyGenderPercentages
)
SELECT
    Country,
    Percent_Female,
    Total_Female
FROM
    CountryPercentages
WHERE
    Percent_Female >= 0
ORDER BY
    Percent_Female DESC;
    
select * from top_countries;

-- #5 % of team's medals won by females and total medals won by females for volume context
drop table if exists female_medals;
CREATE TABLE female_medals
WITH MedalCounts AS (
    SELECT
        t.team AS Country,
        COUNT(*) AS Total_Medals,
        SUM(CASE WHEN a.gender = 'F' AND p.medal_ID < 4 THEN 1 ELSE 0 END) AS Female_Medals
    FROM
        teams t
        JOIN olympians o ON t.team_ID = o.team_ID
        JOIN participants p ON o.olympian_ID = p.olympian_ID
        JOIN athletes a ON o.athlete_ID = a.athlete_ID
        JOIN medals m ON p.medal_ID = m.medal_ID
    WHERE
        p.medal_ID < 4
    GROUP BY
        t.team
)
SELECT
    Country,
    (Female_Medals * 100.0 / Total_Medals) AS Percent_Female_Medals,
    Female_Medals
FROM
    MedalCounts
WHERE
    Female_Medals > 0 
ORDER BY
   Percent_Female_Medals DESC;

Select * from female_medals;

-- #6 select the percentage of female participants, percentage of female medals, and number of female medals into one table to make a chart
drop table if exists medal_join;
CREATE TABLE medal_join AS
SELECT 
    t.country, 
    t.Percent_Female, 
    f.Percent_Female_Medals,
    f.Female_Medals
FROM 
    top_countries t
LEFT JOIN 
    female_medals f 
ON 
    t.country = f.Country
WHERE percent_female_medals is not null;
    
select * from medal_join;

-- end of Molly's queries -- 

-- Topic Area: Ages of Olympians

-- Query 1 | Average Age of Olympians by Sport

-- Description: Link Olympians and Sports tables. Compute average age by sport. Sort results from sports with the oldest
-- average age of Olympians to sports with the youngest average age of Olympians.

SELECT DISTINCT
sport, AVG(age) OVER (PARTITION BY O.sport_ID) AS avg_age_sport
FROM 
Olympians O
INNER JOIN
Sports S
ON O.sport_ID = S.sport_ID
ORDER BY
avg_age_sport DESC;

-- Query 1A | Compute average age of Olympians across the dataset | 25.8001

-- Description: Join Olympians, Athletes, and Sports and calculate average age of Olympians overall 

# Compare to average age of Olympians across the dataset | 25.8001
SELECT
AVG(age)
FROM Olympians;

-- Query 1B | Compute average age of Olympians across the dataset by gender
-- Male: 26.2989 | Female: 24.4349

SELECT DISTINCT
gender,
AVG(age) OVER (PARTITION BY Gender) AS avg_age_gender
FROM 
Olympians O
INNER JOIN
Athletes A
ON A.athlete_ID = O.athlete_ID;

--
--
--

-- Query 2 | Average Age of Olympic Medalists by sport

-- Description: Join Sports, Olympians, and Participants tables. Compute average age of medalists by sport. 
-- Select only cases where athletes won a medal (where medal_ID is 1, 2, or 3). Order from sports with the youngest
-- average age of medalists to sports with the oldest average age of medalists.


SELECT DISTINCT
sport, AVG(age) OVER (PARTITION BY O.sport_ID) AS avg_age_medalists
FROM 
Olympians O
INNER JOIN
Sports S
ON O.sport_ID = S.sport_ID
INNER JOIN
Participants P
ON P.olympian_ID = O.olympian_ID
# Medal ID 1 = Gold, 2 = Silver, 3 = Bronze
WHERE medal_ID IN (1,2,3)
ORDER BY 
avg_age_medalists;

-- Query 2A | Average Age of Olympic Medalists Overall
-- Join Participants and Olympians to get age and medal status. Limit results to medalists.

SELECT DISTINCT
AVG(age) 
FROM 
Olympians O
INNER JOIN
Participants P
ON P.olympian_ID = O.olympian_ID
# Medal ID 1 = Gold, 2 = Silver, 3 = Bronze
WHERE medal_ID IN (1,2,3);

-- Query 2B | Average Age of Olympic Medalists by Gender
-- Join Participants, Athletes, and Olympians to get age, gender, and medal status. Limit results to medalists.

SELECT DISTINCT
gender, 
AVG(age) OVER (PARTITION BY Gender) AS avg_age_gender
FROM 
Olympians O
INNER JOIN
Participants P
ON P.olympian_ID = O.olympian_ID
INNER JOIN 
Athletes A
ON A.athlete_ID = O.athlete_ID
# Medal ID 1 = Gold, 2 = Silver, 3 = Bronze
WHERE medal_ID IN (1,2,3);

--
--
--

-- Query 3 | Average Age of Olympics Medalists by sport and medal type

-- Description: Join Olympians, Sports, and Participants to access sport, medal type, and age. Compute
-- average age of medalists by sport and medal type. Limit results to medalists. Sort from sport, medal type
-- combinations with the highest average ages to sport, medal type combinations with the lowest average ages.

CREATE TABLE avg_age_medal_type_by_sport
SELECT DISTINCT 
sport, medal_ID, AVG(age) OVER (PARTITION BY O.sport_ID, medal_ID) as avg_age_medalists
FROM 
Olympians O
INNER JOIN
Sports S
ON O.sport_ID = S.sport_ID
INNER JOIN
Participants P
ON P.olympian_ID = O.olympian_ID
WHERE medal_ID in (1,2,3)
ORDER BY avg_age_medalists DESC;

-- Query 3A | Average Age of Olympic Medalists by medal type

-- Description: Link Participants and Olympians table to get ages, medal types. Compute average age by medal type.

SELECT DISTINCT
medal_ID,
AVG(age) OVER (PARTITION BY medal_ID) as avg_age_medal
FROM
Olympians O
INNER JOIN
Participants P
ON P.olympian_ID = O.olympian_ID
WHERE medal_ID in (1,2,3);

-- Query 3B | Average Age of Olympics Medalists by gender and medal type

-- Descripton: Link Olympians, Athletes, and Participants to get ages, genders, and medals. Compute average age
-- of medalists by medal type and gender. Limit results to medal winners.

SELECT DISTINCT
gender,
medal_ID,
AVG(age) OVER (PARTITION BY gender, medal_ID) as avg_age_medal
FROM
Olympians O
INNER JOIN
Participants P
ON P.olympian_ID = O.Olympian_ID
INNER JOIN
Athletes A
ON A.athlete_ID = O.athlete_ID
WHERE medal_ID in (1,2,3);

--
--
--

# Query 4 | Average Age of Olympic Medalists by gender and sport

-- Description: Join Olympians, Sports, Participants, and Athletes to get sports, gender, medal status. Compute
-- average age of medalists by gender and sport. Sort results by oldest average age, gender combination 

CREATE TABLE gender_avg_age_medalists AS
SELECT DISTINCT 
sport, gender, AVG(age) OVER (PARTITION BY O.sport_ID, gender) as avg_age_medalists
FROM 
Olympians O
INNER JOIN
Sports S
ON O.sport_ID = S.sport_ID
INNER JOIN
Participants P
ON P.olympian_ID = O.olympian_ID
INNER JOIN
Athletes A
ON O.athlete_ID = A.athlete_ID
WHERE medal_ID in (1,2,3)
ORDER BY avg_age_medalists DESC;


# Query 4A | Find sports with biggest differences between male and female medalists

-- Description: Use gender_avg_age_medalists table created in Query 4. Select average ages of female
-- and male medalists by sport. Use a LEAD function to pull average age of male medalists by sport onto
-- same line as average age of female medalists by sport. Compute differences between average age of male
-- and female medalists. Filter to records where there was a difference between male and female average 
-- medalist ages. Order by sport, from largest gender difference to smallest.
 

WITH Gender_Diffs as 
(SELECT
sport, 
avg_age_medalists,
male_age_medalists,
ABS(avg_age_medalists - male_age_medalists) AS female_male_age_diff

FROM 
(SELECT
sport, gender, avg_age_medalists,
LEAD(avg_age_medalists, 1) OVER(
PARTITION BY sport
ORDER BY gender ASC) AS male_age_medalists
FROM
gender_avg_age_medalists) AS
gender_medal_age_differences)

SELECT sport, avg_age_medalists, male_age_medalists, female_male_age_diff
From Gender_Diffs
WHERE female_male_age_diff IS NOT NULL
ORDER BY female_male_age_diff DESC;


# Query 5 | Find sports with the biggest differences between bronze and gold medalists, where bronze medalists
-- are older than old medalists

-- Description: Use avg_age_medal_type_by_sport table created in Query 3. Select average ages of bronze
-- and gold medalists by sport. Use a LEAD function to pull average age of bronze medalists by sport onto
-- same line as average age of gold medalists by sport. For each sport, compute difference between average age
-- of gold and bronze medalists. For sports where there is a difference greater than 0 (where gold medalists 
-- are younger than bronze medalists), report differences. Sort sports from highest age difference betweeen
-- gold and bronze medalists.

# With younger gold medalists
With age_differences AS

(SELECT 
sport, 
avg_age_medalists as gold_medal_age,
bronze_medal_age,
bronze_medal_age - avg_age_medalists as bronze_gold_difference

FROM
(SELECT
sport, medal_ID, avg_age_medalists, 
LEAD(avg_age_medalists, 1) OVER(
PARTITION BY sport
ORDER BY MEDAL_ID ASC) AS bronze_medal_age
FROM
avg_age_medal_type_by_sport
WHERE medal_ID in (1,3))
AS medal_age_differences)

SELECT sport, gold_medal_age, bronze_medal_age, bronze_gold_difference
FROM age_differences
WHERE bronze_gold_difference > 0
ORDER BY bronze_gold_difference DESC;

# Query 5b | Find sports with the biggest differences between bronze and gold medalists, where gold 
-- medalists are older than bronze medalists.

-- Description: Use avg_age_medal_type_by_sport table created in Query 3. Select average ages of bronze
-- and gold medalists by sport. Use a LEAD function to pull average age of bronze medalists by sport onto
-- same line as average age of gold medalists by sport. For each sport, compute difference between average age
-- of gold and bronze medalists. For sports where there is a difference less than 0 (where gold medalists 
-- are older than bronze medalists), report differences. Sort sports from highest age difference betweeen
-- gold and bronze medalists.

# With older gold medalists
With age_differences AS

(SELECT 
sport, 
avg_age_medalists as gold_medal_age,
bronze_medal_age,
bronze_medal_age - avg_age_medalists as bronze_gold_difference

FROM
(SELECT
sport, medal_ID, avg_age_medalists, 
LEAD(avg_age_medalists, 1) OVER(
PARTITION BY sport
ORDER BY MEDAL_ID ASC) AS bronze_medal_age
FROM
avg_age_medal_type_by_sport
WHERE medal_ID in (1,3))
AS medal_age_differences)

SELECT sport, gold_medal_age, bronze_medal_age, bronze_gold_difference
FROM age_differences
WHERE bronze_gold_difference < 0
ORDER BY bronze_gold_difference ASC;

--
--
--

# Query 6 | Average Age of Olympic Medalists over time, by gender

-- Descripton: Link Olympians, Athletes, Games, and Participants to get ages, genders, Olympic years, 
-- and medal status. Compute average age of medalists by medal type, gender, and Olympic season. 
-- Limit results to medal winners.

SELECT DISTINCT
gender,
year, 
AVG(age) OVER (PARTITION BY gender, year) as avg_age_medal
FROM
Olympians O
INNER JOIN
Participants P
ON P.olympian_ID = O.Olympian_ID
INNER JOIN
Athletes A
ON A.athlete_ID = O.athlete_ID
INNER JOIN
Games G
ON G.olympics_ID = P.olympics_ID
WHERE medal_ID in (1,2,3)
ORDER BY year;

-- end of Nicole's queries -- 

###### BMI Query 1 - What's the raw spread of BMI, for each gender? (primary use for boxplot visual)
SELECT 
    ol.olympian_ID,
    al.gender,
    gm.year,
    (ol.weight / ((al.height / 100) * (al.height / 100))) AS bmi
FROM 
    Olympians ol
JOIN 
    Athletes al ON ol.athlete_ID = al.athlete_ID
JOIN 
Participants pt ON ol.olympian_ID = pt.olympian_ID
JOIN 
    Games gm ON pt.olympics_ID = gm.olympics_ID
WHERE 
    al.height IS NOT NULL AND ol.weight IS NOT NULL;

### BMI Query 2 - How many olympians do NOT fit in the ideal BMI range?
SELECT 
    gm.year,
    COUNT(CASE WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) < 18.5 THEN 1 END) AS count_under,
    COUNT(CASE WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) > 24.9 THEN 1 END) AS count_over,
    COUNT(*) AS total_olympians,                            -- Total number of Olympians in each year
    (COUNT(CASE WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) < 18.5 THEN 1 END) / COUNT(*)) * 100 AS percent_under,
    (COUNT(CASE WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) > 24.9 THEN 1 END) / COUNT(*)) * 100 AS percent_over
FROM 
    Olympians ol
JOIN 
    Athletes al ON ol.athlete_ID = al.athlete_ID
JOIN 
    Participants pt ON ol.olympian_ID = pt.olympian_ID
JOIN 
    Games gm ON pt.olympics_ID = gm.olympics_ID
WHERE 
    al.height IS NOT NULL AND ol.weight IS NOT NULL
GROUP BY 
    gm.year
ORDER BY 
    gm.year desc; 
    
    
### BMI Query 3 - Same question, but for just medal winners
SELECT 
    gm.year,
    COUNT(CASE WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) < 18.5 THEN 1 END) AS count_under,
    COUNT(CASE WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) > 24.9 THEN 1 END) AS count_over,
    COUNT(*) AS total_olympians,                            -- Total number of Olympians in each year
    (COUNT(CASE WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) < 18.5 THEN 1 END) / COUNT(*)) * 100 AS percent_under,
    (COUNT(CASE WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) > 24.9 THEN 1 END) / COUNT(*)) * 100 AS percent_over
FROM 
    Olympians ol
JOIN 
    Athletes al ON ol.athlete_ID = al.athlete_ID
JOIN 
    Participants pt ON ol.olympian_ID = pt.olympian_ID
JOIN 
    Games gm ON pt.olympics_ID = gm.olympics_ID
JOIN 
    Medals md ON pt.medal_ID = md.medal_ID 
WHERE 
    al.height IS NOT NULL AND ol.weight IS NOT NULL
	AND md.medal IN ('Gold', 'Silver', 'Bronze') 
GROUP BY 
    gm.year
ORDER BY 
    gm.year desc; 
 
 ### BMI Query 4 - Do any events have ALL olympians in "healthy" bmi?
 SELECT 
    ev.event_ID, 
    ev.event
FROM 
    events AS ev
JOIN 
    participants AS pt ON ev.event_ID = pt.event_ID
JOIN 
    olympians AS ol ON pt.olympian_ID = ol.olympian_ID
JOIN 
    athletes AS al ON ol.athlete_ID = al.athlete_ID
WHERE 
    al.height IS NOT NULL AND ol.weight IS NOT NULL 
GROUP BY 
    ev.event_ID, ev.event
HAVING 
    COUNT(*) = COUNT(CASE 
                        WHEN (ol.weight / ((al.height / 100) * (al.height / 100))) BETWEEN 18.5 AND 24.9
                        THEN 1 
                    END);
 
 
 
### BMI Query 5 - What are medal winner's BMI doing over time?
SELECT 
    gm.year,
    al.gender,
    md.medal,
    AVG(ol.weight / (al.height/100* al.height/100)) AS average_bmi
FROM 
    participants AS pt
JOIN 
    olympians AS ol ON pt.olympian_ID = ol.olympian_ID
JOIN 
    athletes AS al ON ol.athlete_ID = al.athlete_ID
JOIN 
    games AS gm ON pt.olympics_ID = gm.olympics_ID
JOIN 
    medals AS md ON pt.medal_ID = md.medal_ID
WHERE 
    al.height IS NOT NULL AND ol.weight IS NOT NULL
GROUP BY 
    gm.year, al.gender, md.medal
ORDER BY
	year, gender, medal;