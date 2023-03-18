---total deaths per case
SELECT location,
		date, 
		total_cases ,
		total_deaths ,
		(CAST (total_deaths as float)/ CAST  (total_cases as float ))*100 as deathpercenatge 
from deaths d 
order by 1,2

---total cases in the populations
SELECT location,
		date, 
		population ,
		total_cases ,
		(CAST (total_cases  as float)/ CAST  (population  as float ))*100 as infectionspercenatge 
from deaths d 
WHERE location LIKE '%kenya%'
order by 4 DESC 

--countires with highest infection rates compared to population
SELECT location, 
		population ,
		MAX(CAST (total_cases as integer))as Highestinfectioncount ,
		MAX((CAST (total_cases  as float)/ CAST  (population  as float ))*100) as infectionspercenatge 
from deaths d 
GROUP BY 1,2
order by 4 DESC 

---countries with highest death counts per population
SELECT location,
		population,
		MAX(CAST (total_deaths as integer)) as Highestdeathcount ,
		MAX((CAST (total_deaths as float)/ CAST  (population as float ))*100) as deathpercenatgeinpopulation 
from deaths d 
GROUP BY location ,population 
order by 4 DESC 

---fro contintents
SELECT continent ,
		SUM(population),
		SUM((CAST (total_deaths as integer))) as Highestdeathcount  
from deaths d 
where continent !=''
GROUP BY continent 


SELECT *
FROM deaths d 

--Global numbers
SELECT date ,SUM(new_cases),SUM(new_deaths),
		CAST (SUM(new_deaths) as float)/ CAST (SUM(new_cases) as float) * 100 as deathpercentage
FROM deaths d 
WHERE continent !=''
GROUP BY date 
order by 4 DESC 

SELECT *
FROM vaccinations v 

SELECT *
FROM deaths d 
join vaccinations v 
on d.location =v.location 
and d.date =v.date 

--total population vs total vaccinations
SELECT d.continent ,d.location,
		SUM(population),SUM(CAST (total_vaccinations as int)),
		SUM(CAST (total_vaccinations as float))/SUM(population) *100 as percentageofpopulationvaccinated
FROM deaths d 
join vaccinations v 
on d.location =v.location 
and d.date =v.date 
group by d.continent ,d.location 

SELECT d.continent ,d.location,
		D.date ,population, new_vaccinations,
		sum(new_vaccinations) over (PARTITION by d.location  order by d.location ,d.date) as rollingpeoplevaccinated
FROM deaths d 
join vaccinations v 
on d.location =v.location 
and d.date =v.date 

--use CTE
WITH POPvsVAC (continent,location,date,population ,new_vaccinations,rollingpeoplevaccinated)
AS 
(
SELECT d.continent ,d.location,
		D.date ,population, new_vaccinations,
		sum(new_vaccinations) over (PARTITION by d.location  order by d.location ,d.date) as rollingpeoplevaccinated
FROM deaths d 
join vaccinations v 
on d.location =v.location 
and d.date =v.date
)
SELECT *,(rollingpeoplevaccinated/population)*100 as rollingpercenatagevaccinations
FROM POPvsVAC


--Temp table

create table #PopulationvsVaccinations
(
continent varchar(50),
location varchar(50),
date datetime,
population int,
new_vaccinations int,
rollingpeoplevaccinated int
)
insert into #PopulationvsVaccinations
SELECT d.continent ,d.location,
		D.date ,population, new_vaccinations,
		sum(new_vaccinations) over (PARTITION by d.location  order by d.location ,d.date) as rollingpeoplevaccinated
FROM deaths d 
join vaccinations v 
on d.location =v.location 
and d.date =v.date
SELECT *,(rollingpeoplevaccinated/population)*100 as rollingpercenatagevaccinations
FROM #PopulationvsVaccinations

--creating view for viz
create view Populationvaccinations as
SELECT d.continent ,d.location,
		D.date ,population, new_vaccinations,
		sum(new_vaccinations) over (PARTITION by d.location  order by d.location ,d.date) as rollingpeoplevaccinated
FROM deaths d 
join vaccinations v 
on d.location =v.location 
and d.date =v.date