SELECT
 *
FROM
 PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT
-- *
--FROM
-- PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT
 location,
 date,
 total_cases,
 new_cases,
 total_deaths,
 population
FROM
 PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY
 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT
 location,
 date,
 total_cases,
 total_deaths,
 (total_deaths/total_cases)*100 as DeathPercentage
FROM
 PortfolioProject..CovidDeaths$
WHERE 
 location = 'Ireland'
 AND continent is not null
ORDER BY
 1,2

 -- Looking at the Total Cases vs Population
 -- Shows what percentage of population got Covid

 SELECT
 location,
 date,
 population,
 total_cases,
 (total_cases/population)*100 as PercentPopulationInfected
FROM
 PortfolioProject..CovidDeaths$
--WHERE 
-- location = 'Ireland'
ORDER BY
 1,2


 -- Looking at countries with Highest infection rate compared to population

 SELECT
 location,
 population,
 MAX(total_cases) as HighestInfectionCount,
 MAX((total_cases/population))*100 as PercentPopulationInfected
FROM
 PortfolioProject..CovidDeaths$
--WHERE 
-- location = 'Ireland'
GROUP BY
location,
population
ORDER BY
 PercentPopulationInfected DESC

 -- Showing the countries with the highest death count per population

 SELECT
 location,
 MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
 PortfolioProject..CovidDeaths$
--WHERE 
-- location = 'Ireland'
WHERE continent is not null
GROUP BY
 location
ORDER BY
 TotalDeathCount Desc

  -- Showing the continents with the highest death count

 SELECT
 continent,
 MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
 PortfolioProject..CovidDeaths$
--WHERE 
-- location = 'Ireland'
WHERE continent is not null
GROUP BY
 continent
ORDER BY
 TotalDeathCount Desc

 --GLOBAL NUMBERS

 SELECT
 date,
 SUM(new_cases) AS total_cases,
 SUM(CAST(new_deaths as int)) AS total_deaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 FROM
 PortfolioProject..CovidDeaths$
--WHERE 
-- location = 'Ireland'
WHERE 
continent is not null
GROUP BY
 date
ORDER BY
 1,2


 -- Total population vs vaccinations

SELECT 
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  Vaccs.new_vaccinations,
  SUM(CAST(vaccs.new_vaccinations AS int)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingPopVaccinated
  --, (RollingPopVaccinated/deaths.population)*100
FROM
 PortfolioProject..CovidDeaths$ as deaths
JOIN
 PortfolioProject..CovidVaccinations$ as vaccs
ON
 deaths.location = vaccs.location
AND
 deaths.date = vaccs.date
WHERE
 deaths.continent is not null
ORDER BY
 2,3

 -- Use CTE

 WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPopVaccinated)
as 
(
SELECT 
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  Vaccs.new_vaccinations,
  SUM(CAST(vaccs.new_vaccinations AS int)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingPopVaccinated
  --, (RollingPopVaccinated/deaths.population)*100
FROM
 PortfolioProject..CovidDeaths$ as deaths
JOIN
 PortfolioProject..CovidVaccinations$ as vaccs
ON
 deaths.location = vaccs.location
AND
 deaths.date = vaccs.date
WHERE
 deaths.continent is not null
--ORDER BY
-- 2,3
 )
SELECT *,(RollingPopVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPopVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  Vaccs.new_vaccinations,
  SUM(CAST(vaccs.new_vaccinations AS int)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingPopVaccinated
  --, (RollingPopVaccinated/deaths.population)*100
FROM
 PortfolioProject..CovidDeaths$ as deaths
JOIN
 PortfolioProject..CovidVaccinations$ as vaccs
ON
 deaths.location = vaccs.location
AND
 deaths.date = vaccs.date
WHERE
 deaths.continent is not null
--ORDER BY
-- 2,3

SELECT *,(RollingPopVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
SELECT 
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  Vaccs.new_vaccinations,
  SUM(CAST(vaccs.new_vaccinations AS int)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingPopVaccinated
  --, (RollingPopVaccinated/deaths.population)*100
FROM
 PortfolioProject..CovidDeaths$ as deaths
JOIN
 PortfolioProject..CovidVaccinations$ as vaccs
ON
 deaths.location = vaccs.location
AND
 deaths.date = vaccs.date
WHERE
 deaths.continent is not null
--ORDER BY
-- 2,3

SELECT *
FROM
PercentPopulationVaccinated