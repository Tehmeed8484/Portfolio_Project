select *
from PortfolioProject..CovidDeaths$
where continent  is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccination$
--order by 3,4

--select data that we are going to be using


select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


--- looking at Total Cases vs Population
-- shows what percentage of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as Case_Percentage_over_Population
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


-- looking at countries with Highest Infection Rate compared to population

select location,population,Max(total_cases) as Highest_Infection_count,max((total_cases/population))*100 as Infected_Percentage_over_Population
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by location,population
order by Infected_Percentage_over_Population desc


--Now we are looking at Highest number of people died in different countries
select location,Max(cast(total_deaths as int)) as Maximum_deaths_from_this_countries
from PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by Maximum_deaths_from_this_countries desc



--LET'S BREAK THINGS DOWN BY CONTINENT
select location,Max(cast(total_deaths as int)) as Maximum_deaths_from_this_countries
from PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by Maximum_deaths_from_this_countries desc


-- Showing the Continent with Highest Death Count

--LET'S BREAK THINGS DOWN BY CONTINENT
select location,Max(cast(total_deaths as int)) as Maximum_deaths_from_this_countries
from PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by Maximum_deaths_from_this_countries desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
-- group by date
Order by 1,2

-- Looking at Total Population vs Vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.Date) as Rolling_people_vaccinated
,--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3



--use CTE
WITH PopvsVac (Continent, Location,Date,Population,new_vaccinations, Rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.Date) as Rolling_people_vaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rolling_people_vaccinated/Population)*100
from PopvsVac






-- Temp Tables

drop table if exists #percent_population_Vaccinated
create table #percent_population_Vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date dateTime,
Population numeric,
ew_vaccinated numeric,
Rolling_people_vaccinated numeric
)

insert into #percent_population_Vaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.Date) as Rolling_people_vaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(Rolling_people_vaccinated/Population)*100
from #percent_population_Vaccinated




--Creating view to store data for later visualization


 
Create view uupercent_population_Vaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.Date) as Rolling_people_vaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
 
 select *
 from  uupercent_population_Vaccinated