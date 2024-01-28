WITH MovingAverage_Country AS (
    SELECT
        s.date,
        s.two_letter_country_code,
        s.confirmedcases,
        (s.confirmedcases - LAG(s.confirmedcases, 7) OVER (PARTITION BY s.two_letter_country_code ORDER BY s.date)) / 7.0 AS moving_average
    FROM 
        oxcgrt.statistic AS s
    JOIN 
        oxcgrt.country AS c ON s.two_letter_country_code = c.two_letter_country_code
    JOIN 
        oxcgrt.continent_to_countries AS cc ON cc.two_letter_country_code = s.two_letter_country_code
    WHERE
        s.date = 20221201
),
OverStringencyIndices AS (
    SELECT
        s.date,
        s.two_letter_country_code,
        c.continent_code,
        s.stringencyindex_average_fordisplay / NULLIF(m.moving_average, 0) AS over_stringency_index
    FROM
        oxcgrt.surveys AS s
    JOIN 
        MovingAverage_Country AS m ON s.date = m.date AND s.two_letter_country_code = m.two_letter_country_code
    JOIN 
        oxcgrt.continent_to_countries AS c ON s.two_letter_country_code = c.two_letter_country_code
),
MaxMin_OverStringencyIndices AS (
    SELECT
        date,
        continent_code,
        MAX(over_stringency_index) AS maximum,
        MIN(over_stringency_index) AS minimum
    FROM
        OverStringencyIndices
    WHERE 
        date = 20211201
    GROUP BY
        date, continent_code
),
CountryCode_Index AS (
    SELECT 
        o.date,
        o.continent_code,
        o.maximum,
        o.minimum,
        max_country_code.two_letter_country_code AS max_country_code,
        min_country_code.two_letter_country_code AS min_country_code
    FROM
        MaxMin_OverStringencyIndices AS o
    LEFT JOIN 
        OverStringencyIndices AS max_country_code ON o.maximum = max_country_code.over_stringency_index AND o.continent_code = max_country_code.continent_code AND o.date = max_country_code.date
    LEFT JOIN 
        OverStringencyIndices AS min_country_code ON o.minimum = min_country_code.over_stringency_index AND o.continent_code = min_country_code.continent_code AND o.date = min_country_code.date
),
a AS (
    SELECT
        c.two_letter_country_code,
        c.country_name,
        co.continent_name
    FROM
        oxcgrt.country AS c
    JOIN 
        oxcgrt.continent_to_countries AS cc ON c.two_letter_country_code = cc.two_letter_country_code
    JOIN 
        oxcgrt.continent AS co ON co.continent_code = cc.continent_code
)
SELECT 
    s.date,
    cn.continent_name AS continent,
    max_country_name.country_name AS max_country,
    s.maximum AS max_over_stringency_index,
    min_country_name.country_name AS min_country,
    s.minimum AS min_over_stringency_index
FROM 
    CountryCode_Index AS s
LEFT JOIN 
    a AS max_country_name ON s.max_country_code = max_country_name.two_letter_country_code
LEFT JOIN 
    a AS min_country_name ON s.min_country_code = min_country_name.two_letter_country_code
JOIN 
    oxcgrt.continent AS cn ON cn.continent_code = s.continent_code
ORDER BY
    s.date;