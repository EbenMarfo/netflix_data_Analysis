/*
================================
Netlix Data Analysis
*/

-- Sample Business Questions

-- 1. Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

-- 2. Find the Most Common Rating for Movies and TV Shows
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

-- 3. List All Movies Released in a Specific Year (e.g., 2021)
SELECT * 
FROM netflix
WHERE release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix
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

-- 5. Identify the Longest Movie
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

-- 6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name ILIKE '%Rajiv Chilaka%';

-- 8. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

 -- 9. Count the Number of Content Items in Each Genre
 SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

-- 10.Find each year and the average numbers of content release in India on netflix
-- return top 5 year with highest avg content release
SELECT 
	years,
	ROUND(AVG(total_content), 0) AS average_numbers
FROM 
(
	SELECT 
		EXTRACT(YEAR FROM TO_DATE(date_added, 'month DD, YYYY')) AS years,
		COUNT(show_id) AS total_content
	FROM netflix
	WHERE country ILIKE '%India%'
	GROUP BY 1
) AS TT
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 11. List All Movies that are Documentaries
SELECT 
	title,
	listed_in
FROM netflix 
WHERE type ILIKE 'Movie'
 	AND listed_in ILIKE 'Documentaries';

-- 12. Find All Content Without a Director
SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT COUNT
	(*)
FROM netflix 
WHERE casts ILIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 11

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies 
--Produced in India
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS Actors,
	COUNT(show_id) AS number_appeared
FROM netflix
WHERE type = 'Movie' AND country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
	categories,
	COUNT(*) total_content
FROM
(
	SELECT
		CASE 
			WHEN description ILIKE '%Kill%' OR description ILIKE '%Violence%' THEN 'Bad'
			ELSE 'Good'
			END AS categories
	FROM netflix
)
GROUP BY 1














