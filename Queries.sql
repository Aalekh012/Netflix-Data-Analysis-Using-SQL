-- a) Number of Movies vs TVShows:

select 
	type,
	count (*) as total_content
	from netflix group by type; 
	
-- b) Listing all the movies in a specific year(eg.2020):
		--filter 2020
		--movies released
		
select *from netflix
where type='Movie'
and 
release_year=2020;

--c) Common rating for movies and TVShows:

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

--d) Top 5 countries with the most content on netflix:

SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--e) Longest Movie?:

select * from netflix
	where type='Movie'
	and duration=(select max(duration) from netflix);

--f) Content added in the last 5 years:

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--g) TVShows and Movies directed by Rajiv Chilaka:

select *from netflix
where director ILike'%Rajiv Chilaka%';

--h) TVShows with more than 5 seasons:

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

--i) Number of content items in each genre:

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

--j) each year and the average numbers of content release in India on netflix(returning top 10 year wuth highest average cotent release):

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 10;

--k) Movies that are documentaries:

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

--l) Content without a director and country:

select * from netflix where director is null and country is null;

--m) Number of movies which featured 'Shah Rukh Khan' in last 10 years:

select *from netflix 
WHERE casts LIKE '%Shah Rukh Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- n) Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

--o) Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords:

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;