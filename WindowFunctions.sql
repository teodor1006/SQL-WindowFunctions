CREATE DATABASE WindowsFunctions;

USE WindowsFunctions;

SELECT *
FROM bookings;

-- Window Functions with OVER

-- Average,minimum and maximum price with OVER
SELECT
      id,
      name,
      neighbourhood_group,
      AVG(price) OVER(),
      MIN(price) OVER(),
      MAX(price) OVER()
FROM bookings; 

-- Difference from average price with OVER
SELECT
	id,
	name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2),
	ROUND((price - AVG(price) OVER()), 2) AS diff_from_avg
FROM bookings;

-- Percent of average price with OVER()
SELECT
	id,
	name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2) AS avg_price,
	ROUND((price / AVG(price) OVER() * 100), 2) AS percent_of_avg_price
FROM bookings; 
    
-- Percent difference from average price
SELECT
	id,
	name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2) AS avg_price,
	ROUND((price / AVG(price) OVER() - 1) * 100, 2) AS percent_diff_from_avg_price
FROM bookings;

-- PARTITION BY

-- PARTITION BY neighbourhood group
SELECT
	id,
	name,
	neighbourhood_group,
	neighbourhood,
	price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group
FROM bookings;

-- PARTITION BY neighbourhood group and neighbourhood
SELECT
	id,
	name,
	neighbourhood_group,
	neighbourhood,
	price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group,
	AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood) AS avg_price_by_group_and_neigh
FROM bookings;  

-- Neighbourhood, neighbourhood group and neighbourhood delta
SELECT
	id,
	name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROUND(AVG(price) OVER(PARTITION BY neighbourhood_group), 2) AS avg_price_by_neigh_group,
	ROUND(AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood), 2) AS avg_price_by_group_and_neigh,
	ROUND(price - AVG(price) OVER(PARTITION BY neighbourhood_group), 2) AS neigh_group_delta,
	ROUND(price - AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood), 2) AS group_and_neigh_delta
FROM bookings;    

-- ******************************************************

-- ROW_NUMBER

-- overall price rank
SELECT
	id,
	name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank
FROM bookings;

-- neighbourhood price rank
SELECT
	id,
	name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank
FROM bookings;

-- Top 3
SELECT
	id,
	name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
	CASE
		WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
		ELSE 'No'
	END AS top3_flag
FROM bookings;

-- *********************************************************

-- RANK
SELECT
	id,
	name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
	RANK() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank_with_rank
FROM bookings;

-- DENSE_RANK
SELECT
	id,
	name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_rank,
	DENSE_RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_dense_rank
FROM bookings;

-- *********************************************************

-- LAG BY 1 period
SELECT
	id,
	name,
	host_name,
	price,
	last_review,
	LAG(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LAG BY 2 periods
SELECT
	id,
	name,
	host_name,
	price,
	last_review,
	LAG(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LEAD by 1 period
SELECT
	id,
	name,
	host_name,
	price,
	last_review,
	LEAD(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LEAD by 2 periods
SELECT
	id,
	name,
	host_name,
	price,
	last_review,
	LEAD(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- ******************************************************

-- Top 3 with subquery to select only the 'Yes' values in the top3_flag column
SELECT * 
FROM (
	SELECT
		id,
		name,
		neighbourhood_group,
		neighbourhood,
		price,
		ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
		ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
		CASE
			WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
			ELSE 'No'
		END AS top3_flag
	FROM bookings
	) a
WHERE top3_flag = 'Yes'