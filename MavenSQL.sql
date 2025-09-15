/*engineer these new features for each user, based on their activity, including…
Date from the first movie they finished
Name of the first movie they finished
Date from the last movie they finished
Name of the last movie they finished
Movies started
Movies finished*/

SELECT movie_name, user_id,  SUM(CASE WHEN finished = 1 THEN 1 ELSE 0 END) AS movies_finished
FROM Mavenmovies..activity
GROUP BY user_id, movie_name
ORDER BY user_id


/*SELECT DISTINCT
    user_id, finished, 
    FIRST_VALUE(date) OVER (PARTITION BY user_id ORDER BY date ASC) AS first_movie_date,
    FIRST_VALUE(movie_name) OVER ( PARTITION BY user_id ORDER BY date DESC) AS first_movie_name,
	 FIRST_VALUE(date) OVER (PARTITION BY user_id ORDER BY date DESC) AS Last_movie_date,
    FIRST_VALUE(movie_name) OVER (PARTITION BY user_id ORDER BY date ASC) AS Last_movie_name,
	COUNT(DISTINCT a.movie_name) AS movies_started,
    SUM(CASE WHEN a.finished = 1 THEN 1 ELSE 0 END) AS movies_finished
FROM Mavenmovies..activity a
LEFT JOIN Mavenmovies..users u ON a.user_id = u.id
GROUP BY a.finished, user_id;*/

/*WITH Ranked AS (
    SELECT 
        a.user_id,
        a.movie_name,
        a.date,
        a.finished,
        FIRST_VALUE(date) OVER (PARTITION BY user_id ORDER BY date ASC) AS first_movie_date,
        FIRST_VALUE(movie_name) OVER (PARTITION BY user_id ORDER BY date ASC) AS first_movie_name,
        FIRST_VALUE(date) OVER (PARTITION BY user_id ORDER BY date DESC) AS last_movie_date,
        FIRST_VALUE(movie_name) OVER (PARTITION BY user_id ORDER BY date DESC) AS last_movie_name
    FROM Mavenmovies..activity a
)
SELECT 
    r.user_id,
    r.first_movie_date,
    r.first_movie_name,
    r.last_movie_date,
    r.last_movie_name,
    COUNT(DISTINCT r.movie_name) AS movies_started,
    SUM(CASE WHEN r.finished = 1 THEN 1 ELSE 0 END) AS movies_finished
FROM Ranked r
GROUP BY r.user_id, r.first_movie_date, r.first_movie_name, r.last_movie_date, r.last_movie_name*/








--- Alternatively, using a common table expression CTE

WITH Ranked AS (SELECT 
    user_id,
    movie_name,
    date,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY date ASC) AS rn_first,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY date DESC) AS rn_last,
	SUM(CASE WHEN finished = 1 THEN 1 ELSE 0 END)  OVER (PARTITION BY user_id) AS movies_finished,
	 COUNT(CASE WHEN finished = 0 THEN 1 ELSE 0 END)  OVER (PARTITION BY user_id) AS movies_started_not_completed
  FROM Mavenmovies..activity)
SELECT 
    a.user_id, 
    MIN(CASE WHEN rn_first = 1 THEN r.date END) AS first_movie_date,
    MIN(CASE WHEN rn_last = 1 THEN r.date END) AS last_movie_date,
    MIN(CASE WHEN rn_first = 1 THEN r.movie_name END) AS first_movie_name,
    MIN(CASE WHEN rn_last = 1 THEN r.movie_name END) AS last_movie_name,
	MIN(r.movies_finished) AS movies_finished,
	MIN(r.movies_started_not_completed) AS movies_started_not_completed
    ---COUNT(DISTINCT r.movie_name) AS movies_started_not_completed
   --- SUM(CASE WHEN a.finished = 1 THEN 1 ELSE 0 END) AS movies_finished
FROM Mavenmovies..activity a
LEFT JOIN Mavenmovies..users u ON a.user_id = u.id
LEFT JOIN Ranked r ON u.id = r.user_id
GROUP BY a.user_id
ORDER BY a.user_id

select *
From Mavenmovies..users