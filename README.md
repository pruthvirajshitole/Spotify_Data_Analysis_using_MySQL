# Spotify Advanced SQL Project and Query Optimization
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)
![Spotify Logo](https://github.com/pruthvirajshitole/Spotify_Data_Analysis_using_MySQl/blob/main/spotify_logo.jpg)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 2. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.

#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.

#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 3. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.

---

## 15 Practice Questions

### Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT track FROM spotify
WHERE stream > 1000000000;
```
2. List all albums along with their respective artists.
```sql
SELECT DISTINCT album,artist
FROM spotify
ORDER BY 1;
```
3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql
SELECT SUM(comments) AS Total_No_Comments
FROM spotify
WHERE licensed = 1;
```
4. Find all tracks that belong to the album type `single`.
```sql
SELECT * FROM spotify
WHERE album_type = "single";
```
5. Count the total number of tracks by each artist.
```sql
SELECT
	artist,  -- 1
	COUNT(*) AS total_no_songs  -- 2
FROM spotify
GROUP BY artist
ORDER BY 2;
```
### Medium Level
1. Calculate the average danceability of tracks in each album.
```sql
SELECT
	album,
    AVG(danceability) AS average_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 desc;
```
2. Find the top 5 tracks with the highest energy values.
```sql
SELECT track,energy FROM spotify
ORDER BY energy DESC LIMIT 5;
```
3. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
SELECT
	track,
	SUM(views) AS total_views,
    SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 1
GROUP BY 1
ORDER BY 2 DESC, 3 DESC
LIMIT 5;
```
4. For each album, calculate the total views of all associated tracks.
```sql
SELECT 
	album,
    track,
    SUM(views) AS total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;
```
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
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
```
### Advanced Level
1. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
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
```
2. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT 
	track,
    artist,
    liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);
```
3. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
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
ORDER BY 2 DESC
```

4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
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
```
5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
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
```

Here’s an updated section for **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task you performed. This include the specific screenshots and graphs as described.

---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/pruthvirajshitole/Spotify_Data_Analysis_using_MySQl/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN Before Index](https://github.com/pruthvirajshitole/Spotify_Data_Analysis_using_MySQl/blob/main/spotify_explain_before_index.png)
      ![EXPLAIN After Index](https://github.com/pruthvirajshitole/Spotify_Data_Analysis_using_MySQl/blob/main/spotify_explain_after_index.png)
