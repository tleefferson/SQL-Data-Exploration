Select *
FROM [SQL Tutorial]..covid_deaths$
where continent is not null
order by 3,4

Select *
FROM [SQL Tutorial]..covid_vaccinations$
where continent is not null
order by 3,4

-- Select Data that we are going to be using, order by location then date

Select Location, date, total_cases, new_cases, total_deaths, population
FROM [SQL Tutorial]..covid_deaths$
where continent is not null
order by 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM [SQL Tutorial]..covid_deaths$
where continent is not null and location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, population, (total_cases/population)*100 as PercentPopInfected
FROM [SQL Tutorial]..covid_deaths$
where continent is not null and location like '%states%'
order by 1,2

-- Looking at countries with highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopInfected
FROM [SQL Tutorial]..covid_deaths$
where continent is not null
Group by location, population
order by PercentPopInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths AS int)) as TotalDeathCount 
FROM [SQL Tutorial]..covid_deaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths AS int)) as TotalDeathCount 
FROM [SQL Tutorial]..covid_deaths$
where continent <> '%income%'
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM [SQL Tutorial]..covid_deaths$
where continent is not null
Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations using CTE

With PopvsVac
(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [SQL Tutorial]..covid_deaths$ dea
join [SQL Tutorial]..covid_vaccinations$ vac
	on dea.location = vac.location and dea.date =  vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac


-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [SQL Tutorial]..covid_deaths$ dea
join [SQL Tutorial]..covid_vaccinations$ vac
	on dea.location = vac.location and dea.date =  vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated


-- Creating View to store data for later viz

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [SQL Tutorial]..covid_deaths$ dea
join [SQL Tutorial]..covid_vaccinations$ vac
	on dea.location = vac.location and dea.date =  vac.date
where dea.continent is not null