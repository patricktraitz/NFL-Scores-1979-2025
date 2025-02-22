-- NFL Game Scores Analysis

-- Create TABLE

drop table if exists nfl_data;
create table nfl_data(
	schedule_date date,
	schedule_season int,
	schedule_week varchar(10),
	schedule_playoff varchar(10),
	team_home varchar(25),
	score_home int,
	score_away int,
	team_away varchar(25),
	winner varchar(25),
	team_favorite_id varchar(10),
	spread_favorite float,
	over_under_line float,
	stadium varchar(35),
	stadium_neutral varchar(10),
	weather_temperature int,
	weather_wind_mph int,
	weather_humidity int,
	weather_detail varchar(25)
);

create table nfl_teams(
	team_name varchar(25),
	team_name_short varchar(15),
	team_id varchar(15),
	team_conference varchar(15),
	team_division varchar(15),
	team_conference_pre2002 varchar(25),
	team_division_pre2002 varchar(25)
);

select * 
from nfl_data

--

select *
from nfl_teams

--

select * 
from nfl_data
where weather_temperature is null
	or weather_wind_mph is null
	or weather_humidity is null
	or weather_detail is null

-- Per data source, weather information is from NOAA and NFLweather.com. The null values in 'weather_detail' signfies a condition that was not rain, snow, or fog. 

-- 1. List all the teams that have been in the NFL.

select team_name
from nfl_teams
order by team_name asc

-- 2. Give a list of every Super Bowl winner from 1979, which includes both teams and the final score.

select schedule_season, schedule_week, team_home, score_home, score_away, team_away, winner
from nfl_data
where schedule_week like 'Super Bowl'

-- 3. What team had the largest recorded spread as a favorite?

select distinct min(spread_favorite) as largest_spread, team_favorite_id
from nfl_data
group by team_favorite_id
limit 1

-- 4. What years did the New England Patriots win the Super Bowl?

select schedule_season, schedule_week, winner
from nfl_data
where winner like 'New England Patriots' and schedule_week like 'Super Bowl'

-- 5. Provide a list of the Miami Dolphins' games in which they won in the 2024-2025 season.

select * 
from nfl_data
where schedule_season = 2024 and winner like 'Miami Dolphins' 

-- 6. What division did the 2024-2025 Super Bowl winner come from?

select nd.schedule_week, nd.winner, nt.team_division
from nfl_data nd
	join nfl_teams nt
		on nd.winner = nt.team_name
where schedule_week like 'Super Bowl' and schedule_season = 2024

-- 7. Write a query that shows the season and week a home team or away team won, as well as highlighting if a team won by shutout. 

select schedule_season, schedule_week, team_home, score_home, score_away, team_away,
case
	when score_home > 1 and score_away = 0 then 'HOME SHUTOUT'
	when score_home = 0 and score_away > 1 then 'AWAY SHUTOUT'
	when score_home > score_away then 'Home Win'
	when score_home < score_away then 'Away Win'
end as final_score
from nfl_data

-- 8. What teams pre 2002 were part of the NFC or AFC central division?

select team_name, team_division_pre2002
from nfl_teams
where team_division_pre2002 like '%Central'

-- 9. Write a query that shows a list of games since 1979 that had a 0 degree or below temperature at kickoff.

select *
from nfl_data
where weather_temperature <= 0

-- 10. How many teams have been located in Los Angeles?

select team_name, team_id
from nfl_teams
where team_name like 'Los Angeles%'

-- 11. What is the most points the Miami Dolphins have scored in a home game?

select team_home, score_home as highest_point_total
from nfl_data
where team_home like 'Miami Dolphins'
order by highest_point_total desc
limit 1

-- 12. Sort the team names in ascending order, but have the Miami Dolphins always at the top of the list.

select team_name
from nfl_teams
order by
	case
		when team_name = 'Miami Dolphins' then 0
		else 1 
	end,
team_name

-- 13. What game had the highest over/under line? Provide the season, week, both teams, and final score.

select max(over_under_line) as highest_over_under, schedule_season, schedule_week, team_home, score_home, score_away, team_away
from nfl_data
group by schedule_season, schedule_week, team_home, score_home, score_away, team_away
order by highest_over_under desc
limit 1

-- 14. Write a query to identify the most points scored by an away team since 1979.

select team_away, score_away as highest_point_total
from nfl_data
where score_away = (
	select max(score_away)
	from nfl_data
)