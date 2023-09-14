Select * from 
Select * from dbo.CovidVaccinations order by 3,4

-- Selecting the data to be used

Select location,date, total_cases,new_cases, total_deaths,population from dbo.CovidDeaths Order by 1,2

-- Figuring out total cases vs total deaths
--Chances of Dying if you contract the disease in a particular country

Select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from dbo.CovidDeaths
where location like '%states%'
Order by 1,2

-- Lets see total cases vs population
-- Showing the percentage of population got covid
Select location,date, population,total_cases, (total_cases/population)*100 as DeathPercentage from dbo.CovidDeaths
where location like '%Ind%'
Order by 1,2

-- Looking out countries for highest infection rates
Select location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from dbo.CovidDeaths
--where location like '%states%'
group by location,population
Order by 4 DESC


-- Looking out for countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
Order by 2 DESC

-- Lets break things down by Continents
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is null
group by location
Order by 2 DESC

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
Order by 2 DESC

--Showing the global numbers

Select  SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as deathpercentage 
from dbo.CovidDeaths
--where location like '%Ind%'
where continent is not null
--group by date
Order by 1,2

--Looking at total population  vs vacinnations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3


 --Using CTE:

 With PopvsVac(Continent, Location,Date, Population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 Select *,RollingPeopleVaccinated/population*100 from PopvsVac

 --Tableau queries
 --1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc