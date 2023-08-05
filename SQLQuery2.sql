SELECT *
FROM CovidPortfolioProject..coviddeaths
ORDER BY 3,4

--SELECT *
--FROM CovidPortfolioProject..covidvaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..coviddeaths
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
UPDATE[coviddeaths] SET[total_cases]=NULL WHERE [total_cases]=0
UPDATE[coviddeaths] SET[total_deaths]=NULL WHERE [total_deaths]=0

SELECT CONVERT(INT, total_cases) AS total_cases_int FROM CovidPortfolioProject..coviddeaths
SELECT CONVERT(INT, total_deaths) AS total_deaths_int FROM CovidPortfolioProject..coviddeaths

-- Chance of death when getting COVID in the U.S
SELECT Location, date, total_cases, total_deaths, (CONVERT(decimal, total_deaths))/(CONVERT(decimal, total_cases))*100 AS fatality_rate
FROM CovidPortfolioProject..coviddeaths
WHERE Location = 'United States'
ORDER BY 1,2

--Total cases vs. Population
--What percentage of the population got COVID in the U.S
SELECT Location, date, total_cases, Population, (CONVERT(decimal, total_cases))/(CONVERT(decimal, Population))*100 AS US_infection_rate
FROM CovidPortfolioProject..coviddeaths
WHERE Location = 'United States'
ORDER BY 1,2

--Comparing countries population with infection rate
SELECT Location, Population, MAX(CAST(total_cases AS INT)) AS highest_infection_count, MAX((CONVERT(decimal, total_cases)))/(CONVERT(decimal, Population))*100 AS infection_rate
FROM CovidPortfolioProject..coviddeaths
GROUP BY Location, Population
ORDER BY infection_rate DESC

-- Countries with Highest Death count based on Population
SELECT Location, Population, MAX(CAST(total_deaths AS INT)) AS total_death_count, MAX((CONVERT(decimal, total_deaths)))/(CONVERT(decimal, Population))*100 AS death_rate
FROM CovidPortfolioProject..coviddeaths
GROUP BY Location, Population
ORDER BY death_rate DESC

-- Continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidPortfolioProject..coviddeaths 
GROUP BY continent
ORDER BY total_death_count DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(NULLIF(new_deaths, 0))/SUM(NULLIF(new_cases, 0))*100 AS global_fatality_rate
FROM CovidPortfolioProject..coviddeaths
GROUP BY date
ORDER BY 1,2

--Total Population vs. Vaccinations
UPDATE CovidPortfolioProject..coviddeaths
SET continent = NULLIF(continent, ' ')
UPDATE CovidPortfolioProject..covidvaccinations
SET continent = NULLIF(continent, ' ')
UPDATE CovidPortfolioProject..covidvaccinations
SET new_vaccinations = NULLIF(new_vaccinations, ' ')

WITH Popvsvac (Continent, location, date,  population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM CovidPortfolioProject..coviddeaths dea
JOIN CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM Popvsvac

--View
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM CovidPortfolioProject..coviddeaths dea
JOIN CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
