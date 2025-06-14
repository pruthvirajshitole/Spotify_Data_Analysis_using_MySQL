CREATE DATABASE spotify_db;
USE spotify_db;
DESC spotify;


-- EDA
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE  FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

/*
-- ------------------------------
-- Data Analysis -Easy Category
-- ------------------------------

Q1.Retrieve the names of all tracks that have more than 1 billion streams.
Q2.List all albums along with their respective artists.
Q3.Get the total number of comments for tracks where licensed = TRUE.
Q4.Find all tracks that belong to the album type single.
Q5.Count the total number of tracks by each artist.
*/

-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track FROM spotify
WHERE stream > 1000000000;

-- Q2.List all albums along with their respective artists.

SELECT DISTINCT album,artist
FROM spotify
ORDER BY 1;

-- Q3.Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) AS Total_No_Comments
FROM spotify
WHERE licensed = 1;

-- Q4.Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type = "single";

-- Q5.Count the total number of tracks by each artist.

SELECT
	artist,  -- 1
	COUNT(*) AS total_no_songs  -- 2
FROM spotify
GROUP BY artist
ORDER BY 2;


/*
-- ------------
Medium Level
-- ------------

Q6.Calculate the average danceability of tracks in each album.
Q7.Find the top 5 tracks with the highest energy values.
Q8.List all tracks along with their views and likes where official_video = TRUE.
Q9.For each album, calculate the total views of all associated tracks.
Q10.Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q6.Calculate the average danceability of tracks in each album.

SELECT
	album,
    AVG(danceability) AS average_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 desc;

-- Q7.Find the top 5 tracks with the highest energy values.

SELECT track,energy FROM spotify
ORDER BY energy DESC LIMIT 5;

-- Q8.List all tracks along with their views and likes where official_video = TRUE.

SELECT
	track,
	SUM(views) AS total_views,
    SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 1
GROUP BY 1
ORDER BY 2 DESC, 3 DESC
LIMIT 5;

-- Q9.For each album, calculate the total views of all associated tracks.

SELECT 
	album,
    track,
    SUM(views) AS total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;

-- Q10.Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(SELECT
	track,
    -- most played on
    SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END) as streamed_on_youtube,
    SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END) as streamed_on_spotify
FROM spotify
GROUP BY 1
) AS t1
WHERE 
	streamed_on_spotify > streamed_on_youtube
    AND
    streamed_on_youtube != 0;


/*
-- ------------
Advanced Level
-- ------------

Q11.Find the top 3 most-viewed tracks for each artist using window functions.
Q12.Write a query to find tracks where the liveness score is above the average.
Q13.Use a WITH clause to calculate the difference between the highest and lowest
	energy values for tracks in each album.
Q14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
Q15.Calculate the cumulative sum of likes for tracks ordered by the number of views,
	using window functions
*/

-- Q11.Find the top 3 most-viewed tracks for each artist using window functions.

-- each artist and total views for each track
-- track with highest views for each artist
-- dense rank
-- cte and filder rank<=3

WITH ranking_artist
AS
(SELECT
	artist,
    track,
    SUM(views) AS total_view,
    DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS ranking
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC
 )
SELECT * FROM ranking_artist
WHERE ranking<=3;

-- Q12.Write a query to find tracks where the liveness score is above the average.

SELECT 
	track,
    artist,
    liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- Q13.Use a WITH clause to calculate the difference between the highest and lowest
-- 	   energy values for tracks in each album.

WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC;

-- Q14.Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT
    track,
    artist,
    energy,
    liveness,
    (energy / liveness) AS energy_liveness_ratio
FROM
    spotify
WHERE
    liveness != 0  -- to avoid division by zero
    AND (energy / liveness) > 1.2;

-- Q15.Calculate the cumulative sum of likes for tracks ordered by the number of views,
--     using window functions

SELECT
    track,
    artist,
    views,
    likes,
    SUM(likes) OVER (
        ORDER BY views
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_likes
FROM
    spotify;
