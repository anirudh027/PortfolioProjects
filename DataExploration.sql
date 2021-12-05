select * from Portfolio ..death$
where continent is not null

-- Select the data that we are going to use

Select location,date ,population,new_cases, total_cases, total_deaths from Portfolio ..death$
where continent is not null
order by 1,2



-- Toatal cases VS Total deaths
-- Shows the likelyhood of dying covid in Inida 
Select location,date ,population, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentrage from Portfolio ..death$
Where location like '%india%' 
order by 1,2



--Total cases Vs Population

Select location,date ,population, total_cases, (total_cases/population)*100 as PercentragePopulationInfected from Portfolio ..death$
where continent is not null
order by 1,2



--Countries with highest infection rates Vs population

Select location, population,  MAX(total_cases) as Highest_Cases,
MAX((total_cases/population)*100) as PercentragePopulationIngfected
from Portfolio ..death$
where continent is not null
group by location, population 
order by PercentragePopulationIngfected desc



--Countries with highest death count per population

Select location, population,  MAX(cast(total_deaths as int)) as Total_deaths,
MAX((cast(total_deaths as int)/population)*100)  as PercentragePopulationDeath
from Portfolio ..death$
where continent is not null
group by location, population 
order by PercentragePopulationDeath desc


--Splitting up by continent

Select location as Location,  MAX(cast(total_deaths as int)) as Total_deaths
from Portfolio ..death$
where continent is  null
group by location
order by Total_deaths desc


-- Global Numbers
Select date as Date, SUM(new_cases) as New_Cases,SUM(cast(new_deaths as int)) as New_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as PercentageDeath
from Portfolio ..death$ 
where continent is not null 
group by date
order by 1,2

--Total Global numbers
Select SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as PercentageDeath
from Portfolio ..death$ 
where continent is not null 


--Total population Vs Vaccination

Select death.continent,death.location, death.date,death.population,vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as PeopleVaccinated
from Portfolio..death$ death
join Portfolio..vaccination$ vacc
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null 
order by 2,3


--CTE 
With popvsvac(Continent,Location,Date,Pop,NewVaccinations,PeopleVaccinated)
as
(
Select death.continent,death.location, death.date,death.population,vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as PeopleVaccinated
from Portfolio..death$ death
join Portfolio..vaccination$ vacc
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null 
)

Select *, (PeopleVaccinated/Pop)*100 as PercentPeopleVaccinated
from popvsvac


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent varchar(255),Location varchar(255),Date datetime, population numeric, peoplevaccinated numeric,PercentPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select death.continent,death.location, death.date,death.population,vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as PeopleVaccinated
from Portfolio..death$ death
join Portfolio..vaccination$ vacc
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null 

Select *, (PeopleVaccinated/population)*100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated

--Creating views to store data for visualisations

Create view PercentPopulationVaccinated as
Select death.continent,death.location, death.date,death.population,vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as PeopleVaccinated
from Portfolio..death$ death
join Portfolio..vaccination$ vacc
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null 

