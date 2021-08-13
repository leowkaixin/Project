-- Select Data that we are going to be starting with
SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM [PortfolioProject].[dbo].[CovidDeaths]
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country 
SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases) * 100 AS DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE Location like '%sing%' AND Continent is not null 
ORDER BY 1, 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 AS PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE Location like '%sing%'
ORDER BY 1, 2

-- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(Total_Cases) AS HighestInfectionCount,  Max((Total_Cases/Population))*100 AS PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(Total_Deaths AS int)) AS TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE Continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Showing contintents with the highest death count per population
SELECT Continent, MAX(CAST(Total_Deaths AS int)) AS TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE Continent is not null 
GROUP BY Continent
ORDER BY TotalDeathCount desc

-- Global Numbers 
SELECT SUM(New_Cases) AS TotalCases, SUM(CAST(New_Deaths AS int)) AS TotalDeath, SUM(CAST(New_Deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE Continent is not null 
ORDER BY 1, 2

-- Total Population vs Vaccinations
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations, 
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition By dea.Location, dea.Date) AS RollingPeopleVaccinated 
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent is not null 
ORDER BY 1,2,3

-- Use CTE (Common Table Expression)
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations, 
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition By dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent is not null 
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


-- Temp Table to perform calculation on Partition By in previous query 
DROP TABLE IF EXISTS #PercentPoptulationVaccinated
CREATE TABLE #PercentPoptulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
rollingPeopleVaccinated numeric
)
INSERT INTO #PercentPoptulationVaccinated
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations, 
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition By dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPoptulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPoptulationVaccinated AS
SELECT dea.Continent, dea.Location, dea.Date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent is not null 









