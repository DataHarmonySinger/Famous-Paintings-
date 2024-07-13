select * from artist;
select * from work;
select * from subject;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from image_link;
select * from canvas_size


Q1 Fetch all the paintings which are not displayed on any museums?
SELECT * 
FROM work 
WHERE museum_id IS NULL;

Q2 Are there museums without any paintings?
SELECT m.*
FROM museum m
LEFT JOIN work w ON m.museum_id = w.museum_id
WHERE w.museum_id IS NULL;

Q3 How many paintings have an asking price of more than their regular price?
SELECT COUNT(*)
FROM product_size
WHERE sale_price > regular_price;

Q4 Identify the paintings whose asking price is less than 50% of its regular price 
SELECT w.*
FROM work w
JOIN product_size ps ON w.work_id = ps.work_id
WHERE ps.sale_price < 0.5 * ps.regular_price;

Q5 Which canva size costs the most?
SELECT cs.size_id, MAX(ps.sale_price) AS max_price
FROM canvas_size cs
JOIN product_size ps ON cs.size_id = ps.size_id
GROUP BY cs.size_id
ORDER BY max_price DESC
LIMIT 1;

Q6 Which are the top 5 most popular museum? (Popularity is defined based on most
no of paintings in a museum)
SELECT m.museum_id, m.name, COUNT(w.work_id) AS painting_count
FROM museum m
JOIN work w ON m.museum_id = w.museum_id
GROUP BY m.museum_id, m.name
ORDER BY painting_count DESC
LIMIT 5;

Q7 Who are the top 5 most popular artist? (Popularity is defined based on most no of
paintings done by an artist)
SELECT a.artist_id, a.full_name, COUNT(w.work_id) AS painting_count
FROM artist a
JOIN work w ON a.artist_id = w.artist_id
GROUP BY a.artist_id, a.full_name
ORDER BY painting_count DESC
LIMIT 5;

Q8 Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum
name, museum city and canvas label
WITH most_expensive AS (
    SELECT w.work_id, ps.sale_price, 'Most Expensive' AS price_category
    FROM work w
    JOIN product_size ps ON w.work_id = ps.work_id
    ORDER BY ps.sale_price DESC
    LIMIT 1
),
least_expensive AS (
    SELECT w.work_id, ps.sale_price, 'Least Expensive' AS price_category
    FROM work w
    JOIN product_size ps ON w.work_id = ps.work_id
    ORDER BY ps.sale_price ASC
    LIMIT 1
),
combined AS (
    SELECT * FROM most_expensive
    UNION ALL
    SELECT * FROM least_expensive
)
SELECT a.full_name AS artist_name, c.sale_price, w.name AS painting_name, 
       m.name AS museum_name, m.city AS museum_city, cs.label AS canvas_label, 
       c.price_category
FROM combined c
JOIN work w ON c.work_id = w.work_id
JOIN artist a ON w.artist_id = a.artist_id
JOIN museum m ON w.museum_id = m.museum_id
JOIN product_size ps ON w.work_id = ps.work_id
JOIN canvas_size cs ON ps.size_id = cs.size_id;

Q9 Which Country has the 5th Highest Number of Paintings
SELECT country, painting_count
FROM (
    SELECT m.country, COUNT(w.work_id) AS painting_count
    FROM museum m
    JOIN work w ON m.museum_id = w.museum_id
    GROUP BY m.country
    ORDER BY painting_count DESC
    LIMIT 5
) AS ranked_paintings
ORDER BY painting_count ASC
LIMIT 1;

Q10 Identify the museums which are open on both Sunday and Monday. Display
select m.name as museum_name, m.city
from museum_hours mh1
join museum m on m.museum_id = mh1.museum_id
where day = 'Sunday'
and exists (select 1 from museum_hours mh2
		   where mh2.museum_id = mh1.museum_id
           and mh2.day = 'Monday')
           
Q15 Which museum is open for the longest during a day. Dispay museum name, state
and hours open and which day?
SELECT m.name, m.state, mh.day, 
       (TIMESTAMPDIFF(MINUTE, STR_TO_DATE(mh.open, '%h:%i:%p'), STR_TO_DATE(mh.close, '%h:%i:%p')) / 60) AS hours_open
FROM museum_hours mh
JOIN museum m ON mh.museum_id = m.museum_id
ORDER BY hours_open DESC
LIMIT 1;

Q11 Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.
with cte_country as
        (select country,count(1)
        , rank() over(order by count(1) desc) as rnk
        from museum
        group by country),
	 cte_city as
        (select city,count(1)
        , rank() over(order by count(1) desc) as rnk
        from museum
        group by city)
select country, city
from cte_country
cross join cte_city
where cte_country.rnk = 1
and cte_city.rnk = 1

Q12 Which are the 3 most popular and 3 least popular painting styles?
WITH popular_styles AS (
    -- Most Popular Painting Styles
    SELECT style, COUNT(work_id) AS painting_count
    FROM work
    GROUP BY style
    ORDER BY painting_count DESC
    LIMIT 3
),
unpopular_styles AS (
    -- Least Popular Painting Styles
    SELECT style, COUNT(work_id) AS painting_count
    FROM work
    GROUP BY style
    ORDER BY painting_count ASC
    LIMIT 3
)
SELECT style, painting_count, 'Most Popular' AS category
FROM popular_styles
UNION ALL
SELECT style, painting_count, 'Least Popular' AS category
FROM unpopular_styles;


        