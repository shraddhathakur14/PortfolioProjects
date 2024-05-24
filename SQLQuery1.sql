select*
from Covid_Portfolio..CovidDeaths$
order by 3,4



--select*
--from Covid_Portfolio..CovidVaccination$
--order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from Covid_Portfolio..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths
select location, date, total_cases, total_deaths
from Covid_Portfolio..CovidDeaths$
order by 1,2

--percentage of deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Covid_Portfolio..CovidDeaths$
where location like '%states%'
order by 1,2

--total casses vs population
--shows percentage of population who got covid
select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfected_Percentage
from Covid_Portfolio..CovidDeaths$
where location like '%states%'
order by 1,2

--countries with highest infection rate campared to population
select location, population, MAX(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 as PopulationInfected_Percentage
from Covid_Portfolio..CovidDeaths$
group by location, population
order by PopulationInfected_Percentage desc

----Countries with highest death count per population
select location, MAX(cast(total_deaths AS int)) as Highest_Death_Count
from Covid_Portfolio..CovidDeaths$
where continent is not null
group by location
order by Highest_Death_Count desc

----break things down not by location but by continent

select continent, MAX(cast(total_deaths AS int)) as Highest_Death_Count
from Covid_Portfolio..CovidDeaths$
where continent is not null
group by continent
order by Highest_Death_Count desc

select location, MAX(cast(total_deaths AS int)) as Highest_Death_Count
from Covid_Portfolio..CovidDeaths$
where continent is null
group by location
order by Highest_Death_Count desc

--global numbers 

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Covid_Portfolio..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--deaths and vaccination tables joined on location and date

select *
from Covid_Portfolio..CovidDeaths$ dea
join  Covid_Portfolio..CovidVaccination$ vac
on dea.location =vac.location
and dea.date = vac.date

--total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated_rollingcount
from Covid_Portfolio..CovidDeaths$ dea
join  Covid_Portfolio..CovidVaccination$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--CTE

with POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, Peoplevaccinated_rollingcount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated_rollingcount
from Covid_Portfolio..CovidDeaths$ dea
join  Covid_Portfolio..CovidVaccination$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
)
select*, (Peoplevaccinated_rollingcount/Population)*100 as peoplevaccinated_Percentage
from POPvsVAC

--Temp table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Peoplevaccinated_rollingcount numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated_rollingcount
from Covid_Portfolio..CovidDeaths$ dea
join  Covid_Portfolio..CovidVaccination$ vac
on dea.location =vac.location
and dea.date = vac.date

select * 
from #PercentPopulationVaccinated


--View

create view PercentagePopulationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated_rollingcount
from Covid_Portfolio..CovidDeaths$ dea
join  Covid_Portfolio..CovidVaccination$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null

Select*from PercentagePopulationVaccinated