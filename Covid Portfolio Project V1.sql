select * from PortfolioProject..CovidDeaths
order by 3,4


select * from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2 


-- Looking at the total cases vs total deaths (Percentage of people dying)
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where Location like 'India'
order by 1,2 



--Looking at the total cases versus the population
-- Shows what percent of population got covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where Location like 'India'
order by 1,2 



-- Looking at countries with highest infection rate compared to populations

Select Location,Population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where Location like 'India'
Group By Location, Population
order by PercentPopulationInfected DESC


-- Showing the countries with highest death count per population

Select Location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
--Where Location like 'India'
where continent is not null
Group By Location
order by TotalDeathCount DESC




-- Exploring the data by continent


--Select location, MAX(total_deaths) as TotalDeathCount
--From CovidDeaths
----Where Location like 'India'
--where continent is null
--Group By location
--order by TotalDeathCount DESC

-- Showing the continents with the highest death count


Select continent, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
--Where Location like 'India'
where continent is not null
Group By continent
order by TotalDeathCount DESC




-- Global Numbers
--UPDATE CovidDeaths SET new_cases = NULL WHERE new_cases = 0;
Select date, SUM(new_cases) as TOTAL_CASES, SUM(new_deaths) as TOTAL_DEATHS, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--where location like 'India'
where continent is not null
group by date
order by 1,2

--TOTAL DEATHS WordlWide

Select SUM(new_cases) as TOTAL_CASES, SUM(new_deaths) as TOTAL_DEATHS, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--where location like 'India'
where continent is not null
--group by date
order by 1,2



--Looking at total population vs vaccinated population (per day)

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM (cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,
cd.date) as CumulativeVaccination --,(CumulativeVaccination/population)*100 --> This statement won't run as it is since its not allowed, hence we use a CTE below and execute it.
From CovidDeaths cd
Join CovidVaccinations cv
ON cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null
Order by 2,3


--Using CTE
 
 With PopulationVsVaccination (continent, location, date, population, new_vaccinations, CumulativeVaccination)
 as 
 (
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM (cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,
cd.date) as CumulativeVaccination
From CovidDeaths cd
Join CovidVaccinations cv
ON cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null
--Order by 2,3
)

select *, (CumulativeVaccination/population)*100 as Percent_vaccinated
from PopulationVsVaccination



--Achieving same ouput as CTE USING Temp Table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM (cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,
cd.date) as CumulativeVaccination
From CovidDeaths cd
Join CovidVaccinations cv
ON cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null
--Order by 2,3


select *, (CumulativeVaccination/population)*100 as Percent_vaccinated
from #PercentPopulationVaccinated



--creating view to store data for later visualisations
Select continent, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
--Where Location like 'India'
where continent is not null
Group By continent
order by TotalDeathCount DESC

create view PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM (cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,
cd.date) as CumulativeVaccination
From CovidDeaths cd
Join CovidVaccinations cv
ON cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null
--Order by 2,3


select * 
from PercentPopulationVaccinated