SELECT*
FROM PortfolioProject..Deaths
ORDER BY 3,4;

SELECT*
FROM PortfolioProject..vaccinations
ORDER BY 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Deaths
ORDER BY 1,2

--total cases vs total deaths
--shows likelihood of dying if you are contracted with covid in india

SELECT Location, date, total_cases,  total_deaths,
       100*total_deaths/total_cases AS DeathPercentage
FROM PortfolioProject..Deaths
WHERE Location LIKE '%india%'
ORDER BY 1,2

--looking at total cases vs population
--shows what percentage of population got covid in india

SELECT Location, date, total_cases, population,
       100*total_cases/population AS Percentage_of_affected_population
FROM PortfolioProject..Deaths
WHERE Location LIKE '%india%'
ORDER BY 1,2

--countries with heighest infection rate compared to population

SELECT Location, MAX(total_cases) AS highest_infection_count, population,
       100*MAX(total_cases)/population AS Percentage_of_affected_population
FROM PortfolioProject..Deaths
GROUP BY Location,population
ORDER BY Percentage_of_affected_population DESC

--Showing countries with heighest death percentage compared to population

SELECT Location, MAX(total_deaths) AS highest_death_count, population,
       100*MAX(total_deaths)/population AS Death_Percentage
FROM PortfolioProject..Deaths
GROUP BY Location,population
ORDER BY Death_Percentage DESC

--showing countries with heighest death count

SELECT Location, MAX(cast(total_deaths AS int)) AS highest_death_count
    
FROM PortfolioProject..Deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY highest_death_count DESC

--showing continents with heighest death count


SELECT location, MAX(cast(total_deaths AS int)) AS highest_death_count
FROM PortfolioProject..Deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_death_count DESC 



--GLOBAL NUMBERS 
SELECT date, 
       SUM(new_cases) AS total_cases,
	   SUM(cast(new_deaths AS int)) AS total_deaths,
	   100*SUM(cast(new_deaths AS int))/SUM(new_cases)
FROM PortfolioProject..Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--looking at total population vs vaccination

SELECT d.continent, 
       d.location,
	   d.date,
	   d.population,
	   v.new_vaccinations,
	   SUM(cast(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations_by_date
FROM PortfolioProject..Deaths AS d
JOIN PortfolioProject..vaccinations AS v
ON d.location=v.location AND
   d.date=v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac(continent, location, date, population, new_vaccinations, total_vaccinations_by_date)
AS
(
SELECT d.continent, 
       d.location,
	   d.date,
	   d.population,
	   v.new_vaccinations,
	   SUM(cast(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations_by_date
FROM PortfolioProject..Deaths AS d
JOIN PortfolioProject..vaccinations AS v
ON d.location=v.location AND
   d.date=v.date
WHERE d.continent IS NOT NULL
)
SELECT *,
      100*(total_vaccinations_by_date/population) AS vaccinated_percentage
FROM PopvsVac


--temp table

DROP TABLE IF exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(continent nvarchar(255),
 location nvarchar(255), 
 date datetime,
 population numeric,
 new_vaccinations numeric,
 total_vaccinations_by_date numeric
 )
 INSERT INTO #PercentagePopulationVaccinated
 SELECT d.continent, 
       d.location,
	   d.date,
	   d.population,
	   v.new_vaccinations,
	   SUM(cast(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations_by_date
FROM PortfolioProject..Deaths AS d
JOIN PortfolioProject..vaccinations AS v
ON d.location=v.location AND
   d.date=v.date
WHERE d.continent IS NOT NULL

SELECT *,
      100*(total_vaccinations_by_date/population) AS vaccinated_percentage
FROM #PercentagePopulationVaccinated


--creating views to store data for later visualization

CREATE VIEW PercentagePopulationVaccinated AS
SELECT d.continent, 
       d.location,
	   d.date,
	   d.population,
	   v.new_vaccinations,
	   SUM(cast(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations_by_date
FROM PortfolioProject..Deaths AS d
JOIN PortfolioProject..vaccinations AS v
ON d.location=v.location AND
   d.date=v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated