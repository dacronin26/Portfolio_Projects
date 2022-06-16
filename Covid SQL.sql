SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data for analysis 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths as percentage in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%United States'
AND continent is NOT null 
ORDER BY 1,2

-- Looking at Total Cases vs Population as percentage in the United States 

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_cases
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%United States'
AND continent is NOT null 
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percentage_population_infected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY percentage_population_infected DESC

-- Looking at continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT null
GROUP BY continent
ORDER BY total_death_count DESC

-- Looking at countries with highest death count per popultaion

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT null
GROUP BY location
ORDER BY total_death_count DESC

-- Global death by date  

SELECT date, SUM(new_cases) AS global_new_cases, SUM(CAST(new_deaths AS int)) AS global_new_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percentage_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT null 
GROUP BY date
ORDER BY 1,2

-- Global death total 

SELECT SUM(new_cases) AS global_new_cases, SUM(CAST(new_deaths AS int)) AS global_new_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percentage_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT null 
ORDER BY 1,2

-- Total Population vs Vaccinations

SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations
, SUM(CAST(Vacc.new_vaccinations AS bigint)) OVER (Partition BY Death.location ORDER BY Death.location, Death.date) AS rolling_population_vacc
--, (rolling_population_vacc/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS Death
JOIN PortfolioProject.dbo.CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is NOT null 
ORDER BY 2,3

-- Using CTE 

WITH Pop_vs_Vacc (Continent, location, date, population, new_vaccinations, rolling_population_vacc)
AS
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations
, SUM(CAST(Vacc.new_vaccinations AS bigint)) OVER (Partition BY Death.location ORDER BY Death.location, Death.date) AS rolling_population_vacc
--, (rolling_population_vacc/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS Death
JOIN PortfolioProject.dbo.CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is NOT null 
--ORDER BY 2,3
)
SELECT *, (rolling_population_vacc/population)*100
FROM Pop_vs_Vacc

-- Temp Table

DROP table if exists percent_pop_vacc
CREATE table percent_pop_vacc
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_population_vacc numeric
)

INSERT into percent_pop_vacc
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations
, SUM(CAST(Vacc.new_vaccinations AS bigint)) OVER (Partition BY Death.location ORDER BY Death.location, Death.date) AS rolling_population_vacc
--, (rolling_population_vacc/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS Death
JOIN PortfolioProject.dbo.CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is NOT null 
--ORDER BY 2,3

SELECT *, (rolling_population_vacc/population)*100
FROM percent_pop_vacc

-- Creating view for data visualization 

CREATE VIEW percent_population_vaccination AS
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations
, SUM(CAST(Vacc.new_vaccinations AS bigint)) OVER (Partition BY Death.location ORDER BY Death.location, Death.date) AS rolling_population_vacc
--, (rolling_population_vacc/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS Death
JOIN PortfolioProject.dbo.CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is NOT null 
--ORDER BY 2,3

