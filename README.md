# Netflix Movies & TV Shows Data Analysis Using SQL
![Netflix Logo](https://github.com/NandhuKrisz/netflix_sql_project/blob/main/netflix_logo.jpg)

### Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

### Objectives
- Analyze the distribution of content types (Movies vs TV Shows).
- Identify the most common ratings for Movies and TV Shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

**Dataset Link**: [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)


## Database Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(*) AS count
FROM netflix_raw
GROUP BY type;
```

### 2. Find the Most Common Rating for Movies and TV Shows
```sql
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

```
### 3. List All Movies Released in a Specific Year (e.g., 2020)
```sql
SELECT title
FROM netflix_raw
WHERE release_year = 2020
AND type = 'Movie'

```
### 4. Find the Top 5 Countries with the Most Content on Netflix
```sql
SELECT 
	unnest(string_to_array(country, ', ')) AS country_name, 
	COUNT(*) AS count
FROM netflix_raw
WHERE country IS NOT NULL
GROUP BY country_name
ORDER BY count DESC
LIMIT 5
```
### 5. Identify the Longest Movie
```sql
SELECT title,duration
FROM netflix_raw
WHERE type = 'Movie'
AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration,' ',1)::int DESC
LIMIT 1
```
### 6. Find Content Added in the Last 5 Years
```sql
SELECT type, title
FROM netflix_raw
WHERE TO_DATE(date_added,'Month DD,YYYY')>= CURRENT_DATE - INTERVAL '5 years'
ORDER BY type,title
```
### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
```sql
SELECT title
FROM
(
	SELECT title,TRIM(unnest(string_to_array(director,','))) AS director
	FROM netflix_raw
)x 
WHERE x.director = 'Rajiv Chilaka'

```
### 8. List All TV Shows with More Than 5 Seasons
```sql
SELECT title, SPLIT_PART(duration,' ',1)::INT AS season
	FROM netflix_raw
	WHERE type = 'TV Show'
	AND SPLIT_PART(duration,' ',1)::INT > 5
	ORDER BY season DESC
```
### 9. Count the Number of Content Items in Each Genre
```sql
SELECT TRIM(unnest(string_to_array(listed_in,','))) AS genre,COUNT(*)
FROM netflix_raw
GROUP BY 1
ORDER BY COUNT(*) DESC
```
### 10. Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release!

```sql
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

```
### 11. List All Movies that are Documentaries
```sql
SELECT title
FROM
(
	SELECT title ,TRIM(unnest(STRING_TO_ARRAY(listed_in,','))) AS genre
	FROM netflix_raw
	WHERE type = 'Movie'
) x 
WHERE x.genre = 'Documentaries'

```
### 12. Find All Content Without a Director
```sql
SELECT *
FROM netflix_raw
WHERE director IS NULL
```
### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
SELECT title
FROM netflix_raw
WHERE type ='Movie'
AND "cast" LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM current_date) - 10
```
### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
SELECT 
		TRIM(unnest(STRING_TO_ARRAY(casts,','))) AS casts,
		COUNT(*) AS no_of_movies
	FROM netflix_raw
	WHERE country LIKE '%India%'
	GROUP BY 1
	ORDER BY COUNT(*) DESC
    LIMIT 10
```
### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
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
```

## Findings and Conclusion

- **Content Distribution**: The dataset showcases a wide variety of movies and TV shows, each with different ratings and genres.
- **Common Ratings**: Analyzing the prevalent ratings offers insights into the intended audience for the content.
- **Geographical Insights**: Identifying the leading countries and average content releases from India reveals regional content trends.
- **Content Categorization**: Classifying content using specific keywords enhances the understanding of the types of content available on Netflix.

This analysis delivers a thorough perspective on Netflix's content offerings, which can assist in shaping content strategies and guiding decision-making processes.

