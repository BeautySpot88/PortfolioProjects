select *
from CovidDeaths
where continent is not null
order by 3, 4

--select *
--from CovidVaccinations
--order by 3, 4

--Select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1, 2


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'DeathPercentage'
from CovidDeaths
where location like '%kingdom%'
and where continent is not null
order by 1, 2


-- Looking at total cases vs population 
-- Shows what percentage of popultion has covid

select Location, date, population, total_cases, (total_cases/population)*100 AS 'PercentPopulationInfected'
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1, 2

-- Looking at Countries with the highest infection rate compred to population

select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS 'PercentPopulationInfected'
from CovidDeaths
group by Location, population
order by PercentPopulationInfected desc

-- Showing the countries with the highest death count per population

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


-- Showing continents with the higst death counts
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as 'DeathPercentage'
from CovidDeaths
--where location like '%kingdom%'
Where continent is not null
--Group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
 join CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 order by 2, 3

 -- Use CTE

 With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinatd)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
 join CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
-- order by 2, 3
 )

Select *, (RollingPeopleVaccinatd/Population)*100
From PopvsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated -- prevents duplicates
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinted numeric
)

Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
 join CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
-- order by 2, 3

Select *, (RollingPeopleVaccinted/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualistions

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
 join CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
-- order by 2, 3

Select *
From PercentPopulationVaccinated