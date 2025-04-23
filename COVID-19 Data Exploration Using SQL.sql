/*
Project: COVID-19 Data Exploration

This project involves exploratory analysis of a COVID-19 dataset that includes global statistics on cases, deaths, and vaccinations—organized by country and continent over time.

Key SQL skills demonstrated:
- Joins and Common Table Expressions (CTEs)
- Temporary tables
- Window functions
- Aggregate functions
- View creation
- Data type conversions

The goal is to extract meaningful insights and prepare data for visualization and further analysis.
*/

Select *
From project.CovidDeaths
Where continent is not null 
order by 3,4;


-- Selecting data that will be used in the project

Select Location, date, total_cases, new_cases, total_deaths, population
From project.CovidDeaths
Where continent is not null 
order by 1,2;


-- Comparing Total Cases and Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From project.CovidDeaths
and continent is not null 
order by 1,2;


-- Comparing Total Cases and Population
-- Shows what percentage of population got infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From project.CovidDeaths
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From project.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From project.CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From project.CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From project.CovidDeaths
where continent is not null 
--Group By date
order by 1,2;



-- Comparing Total Population and Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From project.CovidDeaths dea
Join project.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac AS
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
    From project.CovidDeaths dea
    Join project.CovidVaccinations vac
        On dea.location = vac.location
        And dea.date = vac.date
    Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

CREATE VIEW project.PercentPopulationVaccinated AS
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER (
    PARTITION BY dea.location 
    ORDER BY dea.date
  ) AS RollingPeopleVaccinated
FROM project.CovidDeaths dea
JOIN project.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date;
--WHERE dea.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
BEGIN
  CREATE OR REPLACE VIEW project.CovidVaccinations.PercentPopulationVaccinated AS
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT64)) OVER (
      PARTITION BY dea.location 
      ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated,
    (SUM(CAST(vac.new_vaccinations AS INT64)) OVER (
      PARTITION BY dea.location 
      ORDER BY dea.location, dea.date
    ) / dea.population) * 100 AS PercentPopulationVaccinated
  FROM `project.CovidDeaths` dea
  JOIN `project.CovidVaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL;
END;
