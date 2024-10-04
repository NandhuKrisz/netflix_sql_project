
-- 1.  Count the Number of Movies vs TV Shows
-- Objective: Determine the distribution of content types on Netflix.

SELECT type, COUNT(*) AS count
FROM netflix_raw
GROUP BY type



-- 2. Find the Most Common Rating for Movies and TV Shows
-- Objective: Identify the most frequently occurring rating for each type of content

WITH common_ratings AS(
SELECT type,rating, COUNT(*) AS count
FROM netflix_raw
GROUP BY type,rating
ORDER BY COUNT(*) DESC
),
rating AS (
SELECT *,
	RANK() OVER(PARTITION BY type ORDER BY count DESC) AS rank
FROM common_ratings)
SELECT type, rating as most_frequent_rating, count
FROM rating
WHERE rank = 1



-- 3. List All Movies Released in a Specific Year (e.g., 2020)
-- Objective: Retrieve all movies released in a specific year.

SELECT title
FROM netflix_raw
WHERE release_year = 2020
AND type = 'Movie'



-- 4. Find the Top 5 Countries with the Most Content on Netflix
-- Objective: Identify the top 5 countries with the highest number of content items.

SELECT 
	unnest(string_to_array(country, ', ')) AS country_name, 
	COUNT(*) AS count
FROM netflix_raw
WHERE country IS NOT NULL
GROUP BY country_name
ORDER BY count DESC
LIMIT 5



-- 5. Identify the Longest Movie
-- Objective: Find the movie with the longest duration.

SELECT title,duration
FROM netflix_raw
WHERE type = 'Movie'
AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration,' ',1)::int DESC
LIMIT 1

-- 6. Find Content Added in the Last 5 Years
-- Objective: Retrieve content added to Netflix in the last 5 years.
SELECT type, title
FROM netflix_raw
WHERE TO_DATE(date_added,'Month DD,YYYY')>= CURRENT_DATE - INTERVAL '5 years'
ORDER BY type,title


-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
-- Objective: List all content directed by 'Rajiv Chilaka'.
SELECT title
FROM
(
	SELECT title,TRIM(unnest(string_to_array(director,','))) AS director
	FROM netflix_raw
)x 
WHERE x.director = 'Rajiv Chilaka'



-- 8. List All TV Shows with More Than 5 Seasons
-- Objective: Identify TV shows with more than 5 seasons.

	SELECT title, SPLIT_PART(duration,' ',1)::INT AS season
	FROM netflix_raw
	WHERE type = 'TV Show'
	AND SPLIT_PART(duration,' ',1)::INT > 5
	ORDER BY season DESC

-- 9. Count the Number of Content Items in Each Genre
-- Objective: Count the number of content items in each genre.

	SELECT TRIM(unnest(string_to_array(listed_in,','))) AS genre,COUNT(*)
	FROM netflix_raw
	GROUP BY 1
	ORDER BY COUNT(*) DESC



-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
-- Objective: Calculate and rank years by the average number of content releases by India.

SELECT *
FROM netflix_raw

WITH CTE AS
(
	SELECT 
		EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) AS year, 
		TRIM(unnest(string_to_array(country,','))) AS country
	FROM netflix_raw
)
SELECT year,COUNT(*),ROUND((COUNT(*)/SUM(COUNT(*)) OVER())*100)  As avg_number
FROM CTE
WHERE country = 'India'
GROUP BY year
ORDER BY avg_number DESC



-- 11. List All Movies that are Documentaries
-- Objective: Retrieve all movies classified as documentaries.
SELECT title
FROM
(
	SELECT title ,TRIM(unnest(STRING_TO_ARRAY(listed_in,','))) AS genre
	FROM netflix_raw
	WHERE type = 'Movie'
) x 
WHERE x.genre = 'Documentaries'


-- 12. Find All Content Without a Director
-- Objective: List content that does not have a director.

SELECT *
FROM netflix_raw
WHERE director IS NULL

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
-- Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.

SELECT title
FROM netflix_raw
WHERE type ='Movie'
AND "cast" LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM current_date) - 10


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
-- Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.

	SELECT 
		TRIM(unnest(STRING_TO_ARRAY(casts,','))) AS casts,
		COUNT(*) AS no_of_movies
	FROM netflix_raw
	WHERE country LIKE '%India%'
	GROUP BY 1
	ORDER BY COUNT(*) DESC
    LIMIT 10

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
-- Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. 
-- Count the number of items in each category.

SELECT category,COUNT(*)
FROM
(
SELECT title,
			CASE WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%'
			THEN 'Bad'
			ELSE 'Good'
			END AS category
FROM netflix_raw
)x
GROUP BY category
