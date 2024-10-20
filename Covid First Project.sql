select *
from [Porfolio Project1].dbo.CovidDeaths
order by 3,4

select *
from [Porfolio Project1].dbo.CovidVaccinations
order by 3,4


-- select data that we are going to be using 
select Location, date, total_cases, new_cases, total_deaths, population
from [Porfolio Project1].dbo.CovidDeaths
order by 1,2


--Looking at total_cases vs total_deaths
--Showing likelihood of dying if you contact covid in your country
Select location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100 AS DeathPercentage
From [Porfolio Project1]..[CovidDeaths]
Order by 1,2

Select location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100 AS DeathPercentage
From [Porfolio Project1]..[CovidDeaths]
where location like '%state%'
Order by 1,2


--looking at total_cases vs population
--Show what percentage has gotten the covid
Select location, date, total_cases, population, (CAST(total_deaths AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS DeathPercentage
From [Porfolio Project1]. .[CovidDeaths]
where location like '%state%'
Order by 1,2


--looking at countries with highestinfestion rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, max(CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS DeathPercentage
From [Porfolio Project1]..[CovidDeaths]
Group by Location, population
Order by 1,2

Select location, population, max(total_cases) as HighestInfectionCount, max(CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS PercentPopulationInfected
From [Porfolio Project1]..[CovidDeaths]
Group by Location, population
Order by PercentPopulationInfected desc


--Showing countries with Highest Death Count Per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From [Porfolio Project1]..[CovidDeaths]
Group by Location
Order by TotalDeathCount desc

select *
from [Porfolio Project1].dbo.CovidDeaths
Where continent is not null
order by 3,4

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From [Porfolio Project1]..[CovidDeaths]
Where continent is not null
Group by Location
Order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENTS
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [Porfolio Project1]..[CovidDeaths]
Where continent is not null
Group by continent
Order by TotalDeathCount desc

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From [Porfolio Project1]..[CovidDeaths]
Where continent is null
Group by Location
Order by TotalDeathCount desc


--GLOBAL NUMBERS
Select date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100 AS DeathPercentage
From [Porfolio Project1]..[CovidDeaths]
where continent is not null
Order by 1,2

Select date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(CAST(new_cases AS INT)), 0)) * 100 AS DeathPercentage
From [Porfolio Project1].dbo.[CovidDeaths]
where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(CAST(new_cases AS INT)), 0)) * 100 AS DeathPercentage
From [Porfolio Project1].dbo.[CovidDeaths]
where continent is not null
Group by date
Order by 1,2


--Using Covid Vaccination along side
select *
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date


--Looking at the total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3


-- Partition by Location
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location)
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Otherwise:
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location)
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


with PopvsVac (Continent, location, date, population, New_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *
from PopvsVac


with PopvsVac (Continent, location, date, population, New_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Using temp table(Temp Table)

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Using Drop table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later Visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from [Porfolio Project1].dbo.CovidDeaths dea
JOIN [Porfolio Project1].dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
