-- Covid 19 Data Exploration

select * from learning.covid_death
where continent is not null
order by 3, 4;

-- take a look of columns we are going to explore

select location, date, population, total_cases, new_cases, total_deaths
from learning.covid_death
where continent is not null
order by 1, 2;

-- total cases vs population to show what percentage of population contracted with covid

select location, date, population, total_cases, (total_cases/population)*100 as infectionrate
from learning.covid_death
order by 1,2;

-- to show which countries have the highest infection percentage 

select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as population_infected_rate
from learning.covid_death
where location not like 'high_income'
group by location, population
order by population_infected_rate desc;

-- total case vs total deaths to show possibility of dying if infected with covid 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathrate
from learning.covid_death
order by 1, 2;

-- exploring the data by continent
-- showing the continents with highest death toll 

select continent, max(cast(total_deaths as unsigned)) as total_death_count
from learning.covid_death
where continent > ' '
group by continent
order by total_death_count desc;

-- total population vs vaccination

select dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccination
from learning.covid_death dea
join learning.covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1, 2;

-- applying CTE to perform calculation on partition by in above queries

with population_versus_vaccination (location, date, population, new_vaccinations, rollingvaccination)
as 
(
select dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccination
from learning.covid_death dea
join learning.covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (rollingvaccination/population)*100
from population_versus_vaccination




