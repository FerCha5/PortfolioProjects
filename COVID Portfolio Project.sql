SELECT *
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select Data that is going to be use
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths per Country
-- The likelihood of dying if contracting covid in an specific contry
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE location = 'Mexico'
--WHERE location = "Germany"
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total Cases vs Population per Country
--Show what percentage of the population got covid
SELECT Location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
WHERE location = 'Mexico'
--WHERE location = "Germany"
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Looking at Total Cases vs Total Deaths per Continent
-- The likelihood of dying if contracting covid in an specific contry
SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total Cases vs Population per Continent
--Show what percentage of the population got covid
SELECT continent, SUM(population) as total_population, SUM(total_cases) as total_cases,  (sum(total_cases)/sum(population))*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 1

/*SELECT continent, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2*/



--Looking at Continent with Highest Infection Rate compared to Population
SELECT continent, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentPopulationInfected DESC

--Showing the Continent with the Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

/* Correct way to show all data of continents
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC*/

--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths AS INT)) as total_deaths, SUM(cast(new_deaths AS INT))/sum(New_cases)*100 as DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2






--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Use CTE
 WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL