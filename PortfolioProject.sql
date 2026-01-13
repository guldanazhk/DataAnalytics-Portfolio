select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4


--select * 
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--total cases vs total deaths
select location, date, total_cases, total_deaths, concat(round((total_deaths/total_cases)*100, 2), '%') as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Kazakhstan'
order by 1,2


--total cases vs population (какой процент населения заболел)
select location, date, total_cases, population, concat(round((total_cases/population)*100, 4), '%') as CovidSick
from PortfolioProject..CovidDeaths
where location = 'Kazakhstan'
order by 1,2


--countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,  max(concat(round((total_cases/population)*100, 4), '%')) as CovidSick
from PortfolioProject..CovidDeaths
group by location, population
order by CovidSick desc


--countries with the highest death count per population
select location, max(cast(total_deaths as int)) as HighestTotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestTotalDeaths desc


--continents with highest death count
select continent, max(cast(total_deaths as int)) as HighestTotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestTotalDeaths desc


--globally
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, concat(round(sum(cast(new_deaths as int))/(sum(new_cases))*100, 2), '%') as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--cte
with PopOverVac (continent, location, date, population, new_vaccinations, sum_vaccinations)
as
(
-- total population that were vaccinated per day
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
	over (
		partition by dea.location
		order by dea.location, dea.date) as sum_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, (sum_vaccinations/population)*100 as PercentagePeopleVaccinated
from PopOverVac



drop table if exists #PercentagePeopleVaccinated

--temp table
create table #PercentagePeopleVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sum_vaccinations numeric
)

insert into #PercentagePeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
	over (
		partition by dea.location
		order by dea.location, dea.date) as sum_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *, (sum_vaccinations/population)*100 as PercentagePeopleVaccinated
from #PercentagePeopleVaccinated


--creating view for visualization
create view PercentagePeopleVaccinated  as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
	over (
		partition by dea.location
		order by dea.location, dea.date) as sum_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null



select *
from PercentagePeopleVaccinated