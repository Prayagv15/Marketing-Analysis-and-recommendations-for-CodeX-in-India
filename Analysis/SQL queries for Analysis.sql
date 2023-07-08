create database fb;

use fb;

show tables;

select * from dim_cities;

select * from fact_survey_responses;

select * from dim_repondents;

-- 1. What is the consumer base for each energy drink?
with cte as(
  select 
    distinct(current_brands), 
    count(*) over(partition by current_brands) as `Consumer base` 
  from 
    fact_survey_responses
) 
select 
  current_brands,`Consumer base` 
from 
  cte 
order by `Consumer base` desc;

-- 2. Average rating of taste experience of each brand  for their respective consumer base.
with cte as(
  select 
    distinct(current_brands), 
    avg(Taste_experience) over(partition by current_brands) as avg_rating 
  from 
    fact_survey_responses
) 
select 
  current_brands, avg_rating 
from 
  cte 
order by avg_rating desc;

-- 3. Who prefers energy drink more? 
select 
  distinct(Gender), 
  count(*) over(partition by Gender) as `Consumer base` 
from 
  dim_repondents order by `Consumer base` desc;

-- 4. Which age group prefers the Energy drink more?
select 
  distinct(Age) as `Age group`, 
  count(*) over(partition by Age) as `Consumer base` 
from 
  dim_repondents;

-- 5. What is the share of Marketing channels for the energy drinks?
with cte as(
  select 
    count(*) as total 
  from 
    fact_survey_responses), 
cte2 as (
  select 
    distinct(fsr.Marketing_channels), 
    count(*) over(partition by Marketing_channels) `Marketing reach` 
  from 
    fact_survey_responses as fsr 
    inner join dim_repondents as dr on fsr.Respondent_ID = dr.Respondent_ID), 
cte3 as (
  select 
    Marketing_Channels, 
    `Marketing reach` / total * 100 as `Share of marketing channels` 
  from cte, cte2 order by `Share of marketing channels` desc) 
select 
  Marketing_channels, 
  concat(cast(truncate(`Share of marketing channels`, 2) as char),'%') 
  as `Share of marketing channels` from cte3;

  
-- 6. Which type of Marketing reaches the most youth (15-30) for CodeX?
select distinct(fsr.Marketing_channels), 
  count(*) over(partition by Marketing_channels) `Marketing reach` 
from 
  fact_survey_responses as fsr 
  inner join dim_repondents as dr on fsr.Respondent_ID = dr.Respondent_ID 
where 
  Age in ('15-18','19-30') and Current_brands='CodeX';	
  

-- 7. What is the number of Respondents across different cities?  
select 
  distinct(c.city), 
  count(*) over(partition by dr.City_ID) as `Number of respondents` 
from 
  dim_cities as c 
  inner join dim_repondents as dr on c.City_ID = dr.City_ID 
order by 
  `Number of respondents` desc;

-- Number of Respodents based on tier of Cities.
select distinct(c.tier),c.city, count(Respondent_ID) over(partition by c.city) as 
`Consumer base` from dim_cities as c
	inner join dim_repondents as r 
	on c.City_ID=r.City_ID
order by tier, `Consumer base` desc;

-- 8. What are the ingredients of energy preferred among the respondents?
select 
  distinct(Ingredients_expected), 
  count(*) over(
    partition by Ingredients_expected
  ) as `Consumer base` 
from 
  fact_survey_responses;
  
-- 9. What packaging preferences do respondents have for energy drinks?
select 
  distinct(Packaging_preference), 
  count(*) over(
    partition by Packaging_preference
  ) as `Consumer base` 
from 
  fact_survey_responses;
  
-- 10. What are the top reasons for respondents not trying the particular energy drinks?
with cte as (
  select
    distinct(Current_brands),
    count(*) as count,
    Reasons_preventing_trying
  from
    fact_survey_responses
  group by
    Current_brands,
    Reasons_preventing_trying
  order by
    current_brands,
    count desc
),
cte2 as (
  select
    current_brands,
    first_value(Reasons_preventing_trying) over(partition by current_brands) as Reasons_preventing_trying
  from
    cte
)
select
  distinct(current_brands),Reasons_preventing_trying from cte2;


-- 11. What are the primary reasons consumers prefer those brands over others?
with cte as (
  select
    distinct(Current_brands),
    count(*) as count,
    Reasons_for_choosing_brands
  from
    fact_survey_responses
  group by
    Current_brands,
    Reasons_for_choosing_brands
  order by
    current_brands,	
    count desc
),
cte2 as (
  select
    current_brands,
    first_value(Reasons_for_choosing_brands) over(partition by current_brands) as Reasons_for_choosing_brands
  from
    cte
)
select
  distinct(current_brands),Reasons_for_choosing_brands from cte2;
  
-- Count of Reasons for choosing the brand CodeX.
select
    distinct(Current_brands),
    count(*) as count,
    Reasons_for_choosing_brands
  from
    fact_survey_responses
    where current_brands='CodeX'
  group by
    Current_brands,
    Reasons_for_choosing_brands
  order by
    current_brands,	
    count desc;
    
-- 12. What are the share of Different distribution Channels/purchased location?
with cte as (
  select 
    count(*) as total 
  from 
    fact_survey_responses
), 
cte2 as (
  select 
    distinct(Purchase_location), 
    count(*) over(partition by Purchase_location) as count 
  from 
    fact_survey_responses
) 
select 
  purchase_location as `Distribution Channel`, 
  concat(cast(truncate(count / total * 100, 2) as char),'%') as `Share of Distribution Channels` 
from 
  cte,cte2;
  
-- 13. What is the share of Distribution channels for brand 'CodeX'?
with cte as (
  select 
    count(*) as total 
  from 
    fact_survey_responses 
  where Current_brands = 'CodeX'), 
cte2 as (
  select 
    distinct(Purchase_location) as `Distribution Channel`, 
    count(*) over(partition by Purchase_location) as count 
  from 
    fact_survey_responses 
  where 
    Current_brands = 'CodeX') 
select 
  `Distribution Channel`, 
  concat(cast(truncate(count / total * 100, 3) as char), '%') 
  as `Share of Distribution channel for CodeX` 
from cte,cte2;

  
-- 14. Based on the pricing range, what is the energy drink consumer base?
select 
  distinct(Price_range), 
  count(*) over(partition by price_range) as `Consumer Base` 
from 
  fact_survey_responses
  ;

select 
  distinct(Price_range), 
  count(*) over(partition by price_range) as `Consumer Base` 
from 
  fact_survey_responses
where Current_brands='CodeX';

-- 15. What is the consumption frequency for CodeX?
select 
  distinct(Consume_frequency), 
  count(*) over(partition by Consume_frequency) as `Consumer base` 
from 
  fact_survey_responses 
where 
  current_brands = 'CodeX' 
order by 
  `Consumer base` desc;
  
-- 16. What is the consumer base for Limited edition package?
select 
  distinct(Limited_edition_packaging), 
  count(*) over(partition by Limited_edition_packaging) 
    as `Consumer Base` 
from 
  fact_survey_responses 
where 
  current_brands = 'CodeX' 
order by 
  `Consumer Base` desc;
  
-- 17. How many consumers expressed interest in natural and organic drinks?
select 
  distinct(Interest_in_natural_or_organic), 
  count(*) over(
    partition by Interest_in_natural_or_organic) 
    as `Consumer Base` 
from fact_survey_responses 
order by `Consumer Base` desc;

-- 18. What are the improvements desired by consumers of CodeX?
select 
  distinct(Improvements_desired), 
  count(*) over(partition by Improvements_desired) as `Consumer Base` 
from 
  fact_survey_responses 
where 
  Current_brands = 'CodeX' 
order by 2 desc;
