--Analysing the number of Deaths according to the number of Cases.
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..covidDeaths
Order by location, date

-- Looking at the Infection Rate of Various Countries compared to Population
Select location, date, total_cases, total_deaths, (cast(total_cases as float)/population)*100 as InfectedPopulationPercentage
From PortfolioProject..covidDeaths
Order by location, date

--Looking at the Infection Rate of particular Country compared to it's Population
Select location, date, total_cases, total_deaths, (cast(total_cases as float)/population)*100 as InfectedPopulationPercentage
From PortfolioProject..covidDeaths
Where location like '%nepal%'
Order by location, date

--Maximum number of people infected compared to total population
Select location, population, Max(cast(total_cases as float)) as HighestInfected, Max((cast(total_cases as float)/population)*100) as MaximumInfectedPercentage
From PortfolioProject..covidDeaths
Group by location, population
Order by MaximumInfectedPercentage desc


--Total death counts
select location, population, max(cast(total_deaths as int)) as DeathCounts
From PortfolioProject..covidDeaths
Group by location, population
Order by DeathCounts desc

--Countries with high death percentage compared to population
Select location, population, Max(cast(total_deaths as float)) as HighestDeath, Max((cast(total_deaths as float)/population)*100) as MaxDeathpercentage
From PortfolioProject..covidDeaths
Where continent is not null
Group by location, population
Order by MaxDeathpercentage desc

--DeathCounts by Continents
Select continent, Max(cast(total_deaths as float)) as HighestDeath
From PortfolioProject..covidDeaths
Where continent is not null
Group by continent
Order by HighestDeath desc


--Global Data
Select date,sum(cast(new_cases as float)) as total_cases,sum(cast(new_deaths as float)) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as Deathpercentage
From PortfolioProject..covidDeaths
Where new_cases != 0 or new_deaths != 0
Group by date
Order by 1,2

-- New Vaccination compared to population
Select dea.continent, dea.location, dea.date, dea.population, cvac.new_vaccinations
From PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations cvac
	on dea.location = cvac.location
	and dea.date = cvac.date
Where dea.continent is not null
Order By 2,3

--Vaccinations done by location and date
Select dea.continent, dea.location, dea.date, dea.population, cvac.new_vaccinations,
sum(convert(bigint, cvac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_new_vaccination
From PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations cvac
	on dea.location = cvac.location
	and dea.date = cvac.date
Where dea.continent is not null
Order By 2,3


--Population vs Vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_new_vaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, cvac.new_vaccinations,
sum(convert(bigint, cvac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_new_vaccination
From PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations cvac
	on dea.location = cvac.location
	and dea.date = cvac.date
Where dea.continent is not null --and dea.location like '%nepal%'

)
Select *, (rolling_new_vaccination/population)*100 as rolling_new_vaccination_percent
From PopvsVac 


--Temporary Table
Create table #PeopleVaccinatedPercentage
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	NewVaccinations numeric,
	rolling_new_vaccination numeric,
)

Insert into #PeopleVaccinatedPercentage
Select dea.continent, dea.location, dea.date, dea.population, cvac.new_vaccinations,
sum(convert(bigint, cvac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_new_vaccination
From PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations cvac
	on dea.location = cvac.location
	and dea.date = cvac.date
Where dea.continent is not null --and dea.location like '%nepal%'
Order By location, date

Select *, (rolling_new_vaccination/population)*100 as rolling_new_vaccination_percent
From #PeopleVaccinatedPercentage

--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, cvac.new_vaccinations,
sum(convert(bigint, cvac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_new_vaccination
From PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations cvac
	on dea.location = cvac.location
	and dea.date = cvac.date
Where dea.continent is not null --and dea.location like '%nepal%'


Select * From PortfolioProject..covidVaccinations
