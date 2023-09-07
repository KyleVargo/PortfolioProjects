SELECT *
FROM PortfolioProject..CovidDeaths
Where Continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

Select Location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where Continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths

Select Location,date,total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and Continent is not null
order by 1,2

--Looking at Total Cases Vs Population
-- Shows what percentage of the population got Covid
Select Location,date,Population,total_cases, (total_cases/population) *100 PercentPopulationIfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
and Where Continent is not null
order by 1,2

--Looking at Contries with the Highest Infection Rate, compared to Population

Select Location,Population,Max(total_cases)as HighestInfectionCount, Max((total_cases/population)) *100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location,Population
order by PercentPopulationInfected desc

-- Showing Contries with Highest Death Count per Population

Select Location,MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Location
order by TotalDeathCount desc


--Let's Brake things down by contitent



-- Showing the contintents with the highest death count per population

Select Continent,MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
--Where Continent is not null
--group by date
order by 1,2


--Looking at total population Vs Vaccinations

Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM( cast( vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingVaccinations
 --,(RollingVaccinations/population) *100
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.Continent is not null
	order by 2,3
	--Found that I needed to use BIGINT as I was getting  Arithmetic overflow error converting expression to data type int. errors when running it with  SUM( cast( vac.new_vaccinations AS INT)) OVER (Partition by dea.Location)


	--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast( vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingVaccinations
 --,(RollingVaccinations/population) *100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
--order by 2,3
)
Select *, (RollingVaccinations/Population)*100 as PercentOfPopulationVaccinated
From PopvsVac

--Temp Table
Drop table if exists #PrencentPopulationVaccinated
Create Table #PrencentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)


Insert into #PrencentPopulationVaccinated
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast( vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingVaccinations
 --,(RollingVaccinations/population) *100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
--order by 2,3

Select *, (RollingVaccinations/Population)*100 as PercentOfPopulationVaccinated
From #PrencentPopulationVaccinated

--Create Views to store data for later visulizations

Create View PercentOfPopulationVaccinated as
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast( vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingVaccinations
 --,(RollingVaccinations/population) *100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
--order by 2,3

Select *
From PercentOfPopulationVaccinated

Create View TotalDeathCountByContinent as
Select Continent,MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Continent
--order by TotalDeathCount desc

Create View TotalDeathCountByLocation as 
Select Location,MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Location
--order by TotalDeathCount desc
