CREATE DATABASE olympics;

USE olympics;

CREATE TABLE mytable (
  col1 INT,
  col2 INT,
  col3 VARCHAR(10),
  col4 VARCHAR(200)
);


CREATE TABLE `staging` (
  `ID` BIGINT,
  `Name` VARCHAR(1024),
  `Sex` VARCHAR(1024),
  `Age` VARCHAR(1024),
  `Height` VARCHAR(1024),
  `Weight` VARCHAR(1024),
  `Team` VARCHAR(1024),
  `NOC` VARCHAR(1024),
  `Games` VARCHAR(1024),
  `Year` BIGINT,
  `Season` VARCHAR(1024),
  `City` VARCHAR(1024),
  `Sport` VARCHAR(1024),
  `Event` VARCHAR(1024),
  `Medal` VARCHAR(1024),
  `NOC_Region` VARCHAR(1024),
  `NOC_notes` VARCHAR(1024)
);


SELECT * 
FROM staging;

SELECT DISTINCT id,
				name
FROM staging;

SELECT
id,
COUNT(DISTINCT name) as names
FROM staging
GROUP BY id
HAVING COUNT(DISTINCT name)>1;

SELECT
id,
name,
sex, 
COUNT(DISTINCT age) as ages
FROM staging
GROUP BY id, name,
sex
HAVING COUNT(DISTINCT age)>1;

#CHECKING COLUMN SIZES
SELECT
MAX(LENGTH(name)),
MAX(LENGTH(sex)),
MAX(LENGTH(team)),
MAX(LENGTH(noc)),
MAX(LENGTH(noc_region)),
MAX(LENGTH(NOC_notes)),
MAX(LENGTH(event)),
MAX(LENGTH(city)),
MAX(LENGTH(season)),
MAX(LENGTH(sport)),
MAX(LENGTH(games)),
MAX(LENGTH(medal))
FROM olympics.staging;


#CREATE ATHLETE TABLE
CREATE TABLE `Athlete` (
  `Athlete_ID` BIGINT,
  `Name` VARCHAR(1024),
  `Sex` VARCHAR(1024),
  `Height` VARCHAR(1024),
  `Weight` VARCHAR(1024)
  );
  INSERT INTO athlete
SELECT DISTINCT
id as athlete_id,
name,
sex,
NULLIF(height,'') as height,
NULLIF(weight,'') as weight
FROM olympics.staging;
  
  SELECT *
  FROM ATHLETE;
  
#TEAMS TABLE
CREATE TABLE `Teams` (
  `Team_id` BIGINT,
  `Team` VARCHAR(1024),
  `NOC` VARCHAR(1024),
  `NOC_Region` VARCHAR(1024),
  `NOC_Notes` VARCHAR(1024)
  );
  INSERT INTO Teams
SELECT 
ROW_NUMBER() OVER(ORDER BY team) as team_id,
team,
noc,
noc_region,
NOC_notes
FROM ( SELECT DISTINCT team,
				NOC,
                NOC_REGION,
                NOC_NOTES
FROM staging)
AS teams;

SELECT *
FROM TEAMS;

#create events table
CREATE TABLE `Events` (
  `Event_id` BIGINT,
  `Event` VARCHAR(1024),
  `Sport` VARCHAR(1024)
  );
  INSERT INTO Events
SELECT 
ROW_NUMBER() OVER(ORDER BY event,sport) as Event_id,
			EVENT,
            SPORT
FROM ( SELECT DISTINCT EVENT,
				SPORT
FROM staging)
AS Events;

SELECT *
FROM EVENTS;


#CREATE GAMES TABLE
CREATE TABLE `Games` (
  `Games_id` BIGINT,
   `Games` VARCHAR(1024),
  `Year` VARCHAR(1024),
  `Season` VARCHAR(1024),
  `City` VARCHAR(1024)
  );
INSERT INTO Games
SELECT 
ROW_NUMBER() OVER(ORDER BY GAMES) as games_id,
			GAMES,
			YEAR,
            SEASON,
            CITY
FROM ( SELECT DISTINCT GAMES,
				YEAR,
                SEASON,
                CITY
FROM staging)
AS Games;

SELECT *
FROM EVENTS;

DROP TABLE MYTABLE;

#Set Primary Keys
ALTER TABLE athlete ADD PRIMARY KEY(athlete_id);
ALTER TABLE teams ADD PRIMARY KEY(team_id);
ALTER TABLE games ADD PRIMARY KEY(games_id);
ALTER TABLE events ADD PRIMARY KEY(event_id);


#RESULTS
CREATE TABLE results (
  athlete_id INT,
  athlete_age INT,
  team_id INT,
  games_id INT,
  event_id INT, 
  medal VARCHAR(6)
);
INSERT INTO results
SELECT DISTINCT id as athlete_id,
NULLIF(age,'') as athlete_age,
team_id,
games_id,
event_id,
medal
FROM STAGING AS S
INNER JOIN TEAMS AS T ON T.TEAM=S.TEAM
INNER JOIN GAMES AS G ON G.GAMES=S.GAMES AND G.YEAR=S.YEAR AND G.SEASON=S.SEASON
INNER JOIN EVENTS AS E ON E.EVENT=S.EVENT AND E.SPORT=S.SPORT;

SELECT *
FROM RESULTS;

#Set foriegn Keys
ALTER TABLE results ADD FOREIGN KEY (athlete_id) REFERENCES athlete(athlete_id);
ALTER TABLE results ADD FOREIGN KEY (team_id) REFERENCES teams(team_id);
ALTER TABLE results ADD FOREIGN KEY (games_id) REFERENCES games(games_id);
ALTER TABLE results ADD FOREIGN KEY (event_id) REFERENCES events(event_id);
