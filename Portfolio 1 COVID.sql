
-- Data used for project

Select location, date, total_cases, new_cases, total_deaths, population 
From  CovidDeaths 
Where continent is not null 
Order by location, date 

-- Total cases versus total deaths in Australia 
-- Shows the likelihood of dying if you contract covid in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
From  CovidDeaths 
Where continent is not null and location = 'Australia' 
Order by location, date

-- Total Cases versus population 
-- Shows what percentage of population infected with Covid

Select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as Case_Percentage 
From  CovidDeaths 
Where continent is not null 
Order by location, date

-- Countries with the highest infection rate by population 

Select location, population, max (total_cases) as highest_cases, population, MAX((total_cases/population))*100 as Case_Percentage 
From  CovidDeaths 
Where continent is not null  
Group by location, population 
Order by Case_Percentage  Desc 

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Breaking data down by continent 
-- Highest death per population by continent 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc 

-- Global Numbers

Select SUM(New_cases) as Global_case_count, SUM(cast(new_deaths as int)) as Global_Deaths_count, SUM(cast(new_deaths as int))/SUM(New_cases) as Percentage_of_deaths
From CovidDeaths
Where continent is not null 

-- Rolling count of people vacinated by country 

Select Deaths.continent, Deaths.Location, Deaths.Date, Deaths.Population, Vac.new_Vaccinations,SUM (Cast(Vac.new_Vaccinations as int)) Over (Partition by Deaths.Location order by Deaths.Location, Deaths.date) as Rolling_count_of_vacs
From CovidDeaths Deaths 
Join CovidVaccinations  Vac
	on Deaths.Location = Vac.Location
	and Deaths.date = Vac.date
Where Deaths.continent is not null 
Order by Location, date  

--  Percentage of Population that has recieved at least one Covid Vaccine
-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (Continent, location, date, population , new_Vaccinations, Rolling_count_of_vacs)

as 
(
Select Deaths.continent, Deaths.Location, Deaths.Date, Deaths.Population, Vac.new_Vaccinations,SUM (Cast(Vac.new_Vaccinations as int)) Over (Partition by Deaths.Location order by Deaths.Location, Deaths.date) as Rolling_count_of_vacs
From CovidDeaths Deaths 
Join CovidVaccinations  Vac
	on Deaths.Location = Vac.Location
	and Deaths.date = Vac.date
Where Deaths.continent is not null 
) 

 Select * , (Rolling_count_of_vacs/population) * 100 as rolling_count_percentage_Vaccinated
 From popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #Percentage_Population_Vaccinated
Create Table #Percentage_Population_Vaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
Rolling_count_of_vacs numeric,
) 

Insert into #Percentage_Population_Vaccinated 
Select Deaths.continent, Deaths.Location, Deaths.Date, Deaths.Population, Vac.new_Vaccinations,SUM (Cast(Vac.new_Vaccinations as int)) Over (Partition by Deaths.Location order by Deaths.Location, Deaths.date) as Rolling_count_of_vacs
From CovidDeaths Deaths 
Join CovidVaccinations  Vac
	on Deaths.Location = Vac.Location
	and Deaths.date = Vac.date
Where Deaths.continent is not null 

 Select * , (Rolling_count_of_vacs/population) * 100 as rolling_count_percentage_Vaccinated
 From #Percentage_Population_Vaccinated
 
 -- Creating view to store data for later visulalizations

 Create view Percentage_Population_Vaccinated as 
 Select Deaths.continent, Deaths.Location, Deaths.Date, Deaths.Population, Vac.new_Vaccinations,SUM (Cast(Vac.new_Vaccinations as int)) Over (Partition by Deaths.Location order by Deaths.Location, Deaths.date) as Rolling_count_of_vacs
From CovidDeaths Deaths 
Join CovidVaccinations  Vac
	on Deaths.Location = Vac.Location
	and Deaths.date = Vac.date
Where Deaths.continent is not null 
