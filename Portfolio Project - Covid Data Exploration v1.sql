select *
from PortfolioProject..CovidDeaths
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- Select the data that we're going to be using

select location, date, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at percecntage of total_deaths vs total_cases 
-- Shows the likelihood of dying if you contract covid in your country-- Shows the likelihoodof dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%indo%'
order by 1,2

-- Looking at Total Cases vs Population 
-- in Indonesia
select location, date, total_cases, population, (total_cases/population)*100 as Cases_Percentage
from PortfolioProject..CovidDeaths
--where location like '%indo%'
order by 1,2


-- Looking at the country with highest infection rate vs population
select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths
--where location like '%indo%'
Group by Location, Population
order by Percent_Population_Infected DESC

-- Looking at the country with highest death count vs population

select location, population, MAX(cast(total_deaths as int)) as Highest_Deaths_Count, MAX((cast(total_deaths as int)/population))*100 as Percent_Population_Deaths
from PortfolioProject..CovidDeaths
--where location like '%indo%'
Group by Location, Population
order by Highest_Deaths_Count DESC

-- Looking at the country with highest death count vs population
-- Don't show the CONTINENT as Location
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select location, population, MAX(cast(total_deaths as int)) as Highest_Deaths_Count, MAX((cast(total_deaths as int)/population))*100 as Percent_Population_Deaths
from PortfolioProject..CovidDeaths
--where location like '%indo%'
where continent is not null
Group by Location, Population
order by Highest_Deaths_Count DESC

-- SHOWING THE CONTINENT WHICH HAS THE COUNTRY WITH HIGHEST DEATH COUNT
-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as Highest_Deaths_Count
from PortfolioProject..CovidDeaths
--where location like '%indo%'
where continent is not null
Group by continent
order by Highest_Deaths_Count DESC

-- 
-- SHOWING THE CONTINENT WITH HIGHEST DEATH COUNT
select location, MAX(cast(total_deaths as int)) as Highest_Deaths_Count
from PortfolioProject..CovidDeaths
--where location like '%indo%'
where continent is null
Group by location
order by Highest_Deaths_Count DESC

-- GLOBAL NUMBERS
select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
-- where location like '%indo%'
where continent is not null
group by date
order by 1,2

-- GLOBAL NUMBERS
-- use aggregate functions
select date, sum(max(total_cases)), total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
-- where location like '%indo%'
where continent is not null
group by date
order by 1,2

-- use aggregate functions
select date, sum(new_cases)--, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
-- where location like '%indo%'
where continent is not null
group by date
order by 1,2

-- use aggregate functions
select date, sum(new_cases) as SumCases, sum(cast(new_deaths as int)) as SumDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from PortfolioProject..CovidDeaths
-- where location like '%indo%'
where continent is not null
group by date
order by date desc

--GLOBAL TOTAL DEATHS VS TOTAL CASES
select sum(new_cases) as SumCases, sum(cast(new_deaths as int)) as SumDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from PortfolioProject..CovidDeaths
-- where location like '%indo%'
where continent is not null
--group by date
order by 1,2


--USE VACCINATION DATA
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Total Vaccination
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as New_Vaccination
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- and dea.location like '%indo%'
--order by New_Vaccination DESC
order by 2,3

-- LOOKING THE AUTOMATIC COUNT OF TOTAL VACCINATION
-- Looking at Total Population vs Total Vaccination
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as New_Vaccination
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- and dea.location like '%indo%'
--order by New_Vaccination DESC
order by 2,3

-- LOOKING THE AUTOMATIC COUNT OF ROLLING VACCINATION
-- Looking at Total Population vs Total Vaccination
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as New_Vaccination
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vaccination
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%indo%'
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as New_Vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vaccinated
--, (Rolling_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%indo%'
--order by 2,3
)
Select *, (Rolling_Vaccinated/Population)*100 as Vac_per_Pop
From PopvsVac
--order by New_Vaccinations desc



-- TEMP TABLE


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vaccinated
--, (Rolling_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%indo%'
--order by 2,3

Select *, (Rolling_Vaccinated/Population)*100 as Vac_per_Pop
From #PercentPopulationVaccinated
--order by New_Vaccinations desc

DROP TABLE #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vaccinated
--, (Rolling_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%indo%'
--order by 2,3

Select *
From Percent_Population_Vaccinated