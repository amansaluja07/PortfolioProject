--

Select *
FROM [Portfolio Project]..CovidDeaths
where continent is not Null
Order by 3,4

Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%' and continent is not Null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Showing the countries with the highest Death Count per Population 

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is not Null
Group by location
Order by TotalDeathCount desc

-- -- Showing the contients with the highest Death Count per Population 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is Null and location not in('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is not Null
Group by continent
Order by TotalDeathCount desc

--Showing the continents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not Null
Group by date
order by 1,2 desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not Null
order by 1,2 desc

--Looking at Total Population vs vaccinations

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(CD.new_vaccinations as int)) OVER(Partition by CD.location order by CD.location, CD.date) as Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths as CD
JOIN [Portfolio Project]..CovidVaccinations as CV
ON CD.location=CV.location and CD.date=CV.date
where CD.continent is not null
order by 2,3


--Use CTE

With PopvsVac(Continent,location,date,population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(CD.new_vaccinations as int)) OVER(Partition by CD.location order by CD.location, CD.date) as Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths as CD
JOIN [Portfolio Project]..CovidVaccinations as CV
ON CD.location=CV.location and CD.date=CV.date
where CD.continent is not null
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(CD.new_vaccinations as int)) OVER(Partition by CD.location order by CD.location, CD.date) as Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths as CD
JOIN [Portfolio Project]..CovidVaccinations as CV
ON CD.location=CV.location and CD.date=CV.date
where CD.continent is not Null
order by 2,3

Select *, (Rolling_People_Vaccinated/population)*100
From #PercentPopulationVaccinated

--Craeting view to store data for later visualization

Create View PercentPopulationVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(CD.new_vaccinations as int)) OVER(Partition by CD.location order by CD.location, CD.date) as Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths as CD
JOIN [Portfolio Project]..CovidVaccinations as CV
ON CD.location=CV.location and CD.date=CV.date
where CD.continent is not Null
--order by 2,3

Select *
FROM PercentPopulationVaccinated