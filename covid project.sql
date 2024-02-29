SELECT *
FROM PortfolioProject..CovidDeath$
Where continent is not null
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination$
--Order by 3,4

-- Select Data that will be used 

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath$
WHERE Location like '%africa%'
Order by 1,2

-- Total Cases Vs Total Deaths
-- Shows the likelihood of dying if a person contracted Covid-19 in a country
Select Location, date, total_cases, total_deaths, (cast(total_deaths as int) /cast(total_cases as int)) *100 as DeathPercentage 
From PortfolioProject..CovidDeath$
WHERE Location like '%states%'
and continent is not null
Order by 1,2 DESC


-- Total cases Vs poputaion

Select Location, date, total_cases, population, (cast(total_cases as int) /population ) *100 as CasePercentage 
From PortfolioProject..CovidDeath$
--WHERE Location like '%states%'
Order by 1,2 DESC

-- Countries with Highst Infection Rate compared to Population

Select Location, date, MAX(total_cases) as HighestInfectionCount, population, Max(total_cases/population ) *100 as PercentagePopulationInfected
From PortfolioProject..CovidDeath$
--WHERE Location like '%states%'
Group by Location, Population
Order by PercentagePopulationInfected DESC

-- Showing the countries with highest death count per population

Select Location, Max(Cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
--WHERE Location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Divde data by Continent

Select location, Max(Cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
--WHERE Location like '%states%'
Where continent is  Null
Group by location
Order by TotalDeathCount desc

-- Showing Continents with the highest death count per population

Select continent, Max(Cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
--WHERE Location like '%states%'
Where continent is not Null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

Select  SUM(new_cases) Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths , 
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath$
--WHERE Location like '%states%'
Where continent is not null
--Group by date
Order by 1,2 

-- Total Population vs vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 Order by 2,3

 --Use a CTE

 With PopvsVac (Continent, Location, date, Population,New_Vaccinations, RollingPeopleVaccinated)
 as

 (Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --Order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac

 --TEMP TABLE
 DROP Table if exists #PercentagePopulationVaccinated
 Create Table #PercentagePopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255), 
 Date datetime,
 Population numeric,
 New_vaccinations numeric, 
 RollingPeopleVaccinated numeric
 )

 INSERT INTO  #PercentagePopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --Order by 2,3

 Select * , (RollingPeopleVaccinated/Population)*100
 From #PercentagePopulationVaccinated


 --Creating View to store data for Later Visualizations

 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated