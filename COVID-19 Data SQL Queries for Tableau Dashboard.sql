/*
COVID-19 Data SQL Queries for Tableau Dashboard

This script contains the four main SQL queries used to prepare datasets for Tableau visualizations. 
The queries were executed in Google BigQuery and exported as CSV files, which were then uploaded 
to Tableau Public to build an interactive COVID-19 dashboard.

Each query focuses on a different perspective of the data:
1. Global total cases, deaths, and calculated death percentage
2. Total death count by continent (excluding global aggregates)
3. Highest infection counts and population infection percentages by country
4. Daily progression of infection rates by country
*/

-- 1.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From project.CovidDeaths
where continent is not null 
order by 1,2;

-- 2.

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From project.CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From project.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From project.CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
