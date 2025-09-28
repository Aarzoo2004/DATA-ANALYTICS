USE PortfolioProject;

SELECT *
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4;


-- Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths$
WHERE Location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS case_percentage
FROM CovidDeaths$
WHERE Location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PeakInfectionRate
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PeakInfectionRate DESC;


-- Showing Countries with Highest Death Count per Population

SELECT Location, population, MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC;


-- Filtering w.r.t Continent
-- Showing Continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

SELECT location, MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;


-- Global Numbers

SELECT date, SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Looking at Total Population vs Vaccinations
-- USE CTE

WITH vaccinations_per_population (continent, location, date, population,new_vaccinations, RollingVaccinations) AS
(
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    MAX(cd.population) as population,
    MAX(cv.new_vaccinations) as new_vaccinations,
    SUM(MAX(CAST(ISNULL(cv.new_vaccinations, 0) AS BIGINT))) 
    OVER (PARTITION BY cd.location ORDER BY cd.date) AS RollingVaccinations
FROM CovidDeaths$ AS cd
JOIN CovidVaccinations$ AS cv
    ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.continent, cd.location, cd.date
)
SELECT *, (RollingVaccinations/population)*100
FROM vaccinations_per_population
ORDER BY 2, 3;


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    MAX(cd.population) as population,
    MAX(cv.new_vaccinations) as new_vaccinations,
    SUM(MAX(CAST((cv.new_vaccinations) AS BIGINT))) 
    OVER (PARTITION BY cd.location ORDER BY cd.date) AS RollingVaccinations
FROM CovidDeaths$ AS cd
JOIN CovidVaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
GROUP BY cd.continent, cd.location, cd.date;

SELECT *, (RollingVaccinations/population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    MAX(cd.population) as population,
    MAX(cv.new_vaccinations) as new_vaccinations,
    SUM(MAX(CAST((cv.new_vaccinations) AS BIGINT))) 
    OVER (PARTITION BY cd.location ORDER BY cd.date) AS RollingVaccinations
FROM CovidDeaths$ AS cd
JOIN CovidVaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.continent, cd.location, cd.date;

SELECT *
FROM PercentPopulationVaccinated;