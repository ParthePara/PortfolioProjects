/*
COVID-19 Data Exploration

Skills used: Joins, CTEs, Temp. Tables, Windows Functions, Aggregate Funcions, Creating Views, Converting Data Types
*/


-- 1) Start by looking at ALL the data broadly
SELECT *
FROM PortfolioProject1..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinations
ORDER BY 3,4

-- 2) Select Data that I am going to be starting with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- 3) Total Cases vs. Total Deaths
-- Purpose: Shows likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, ROUND((cast(total_deaths as int)/total_cases)*100,2) AS DeathsToCases
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL AND location = 'Canada'
ORDER BY 1,2

-- 4) Total Cases vs. Population
-- Purpose: Shows what percentage of population has contracted COVID in Canada
SELECT location, date, total_cases, population, 
ROUND((total_cases/population)*100,2) AS CasesToPopulation
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL AND location = 'Canada'
ORDER BY 1,2

-- 5) Countries with Highest Per Capita Infection Rate
SELECT location, population, MAX(total_cases) AS TotalInfectionCount,
MAX(total_cases)/population*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 6) Countries with Highest Per Capita Death Rate
SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount,
MAX(CAST(total_deaths AS int))/population*100 AS PercentPopulationDeseased
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationDeseased DESC


-- Breaking Things Down by Continent --


-- 7) Total Death Count by Continent
SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NULL AND location IN ('World', 'North America', 
'South America', 'Asia', 'Europe', 'Africa', 'Oceania')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS --

-- 8) Global day-by-day new cases and new deaths
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- VACCINATIONS --

-- 9) Looking at Total Population vs Vaccine Doses Received
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- 10) Calculating a daily rolling count of total new vaccine doses received
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint, vax.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.date) AS VaxDoseRollingCount
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- 11) Using a CTE to perform Caluculaiton on Partition by in previous query 
-- Purpose: calculate the percentage of population in every country with at least 2 doses reveiced
WITH PopVsVax (Continent, Location, Date, Population, New_Vaccinations, VaxDoseRollingCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint, vax.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.date) AS VaxDoseRollingCount
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
)
SELECT Continent, Location, Population, MAX(VaxDoseRollingCount) AS TotalDoses,
ROUND((MAX(VaxDoseRollingCount)/2/Population)*100,4) AS PercentageWith2Doses
FROM PopVsVax
GROUP BY Continent, Location, Population
ORDER BY 2

-- 12) Using Temp Table to perform Calculation on Partition By in previous query
-- Purpose: calculate the percentage of population in every country with at least 2 doses reveiced
DROP TABLE IF EXISTS #PercentPopulationWith2Doses
CREATE TABLE #PercentPopulationWith2Doses
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations float,
TotalDosesRollingCount bigint,
)

INSERT INTO #PercentPopulationWith2Doses
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint, vax.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.date) AS VaxDoseRollingCount
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL

SELECT Continent, Location, Population, MAX(TotalDosesRollingCount) AS TotalDoses,
ROUND((MAX(TotalDosesRollingCount)/2/Population)*100,4) AS PercentageWith2Doses
FROM #PercentPopulationWith2Doses
GROUP BY Continent, Location, Population
ORDER BY 2

-- 13) Creating View to store data for later visualizations
DROP VIEW IF EXISTS RollingCountDosesGiven
CREATE VIEW RollingCountDosesGiven AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint, vax.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.date) AS VaxDoseRollingCount
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
