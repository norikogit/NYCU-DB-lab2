WITH StringencyIndex AS (
    SELECT
        date,
        CC.continent_code,
        MAX(stringencyindex_average_fordisplay) AS Maximum,
        MIN(stringencyindex_average_fordisplay) AS Minimum
    FROM
        oxcgrt.surveys as o
    join oxcgrt.continent_to_countries as CC on CC.two_letter_country_code = o.two_letter_country_code
    WHERE 
        date = 20200401
    GROUP BY
        date, CC.continent_code
),
CountryCode_Index AS (
    SELECT 
        S.Date,
        S.Continent_Code,
        S.Maximum,
        MaxCC.Two_Letter_Country_Code AS Max_CountryCode,
        S.Minimum,
        MinCC.Two_Letter_Country_Code AS Min_CountryCode
    FROM
        StringencyIndex AS S
    LEFT JOIN oxcgrt.surveys AS MaxCC ON S.Maximum = MaxCC.stringencyindex_average_fordisplay 
        AND S.Date = MaxCC.Date
    LEFT JOIN oxcgrt.surveys AS MinCC ON S.Minimum = MinCC.stringencyindex_average_fordisplay 
        AND S.Date = MinCC.Date
    ORDER BY
        S.Date, S.Continent_Code
),
Country_N_Continent AS (
    SELECT
        C.two_letter_country_code,
        C.country_name,
        CC.continent_code,
        CT.continent_name
    FROM
        oxcgrt.country AS C
    JOIN oxcgrt.continent_to_countries as CC ON C.two_letter_country_code = CC.two_letter_country_code
    JOIN oxcgrt.continent AS CT ON CC.continent_code = CT.continent_code
)
SELECT
    CCI.Date,
    CCI.continent_code,
    CCI.Maximum AS Max_Stringency_Index, 
    MaxCountryName.country_name AS Max_Country_Name,
    CCI.Minimum AS Min_Stringency_Index,
    MinCountryName.country_name AS Min_Country_Name
FROM
    CountryCode_Index AS CCI
LEFT JOIN Country_N_Continent AS MaxCountryName
    ON CCI.Max_CountryCode = MaxCountryName.two_letter_country_code
    AND CCI.Continent_Code = MaxCountryName.continent_code
LEFT JOIN Country_N_Continent AS MinCountryName
    ON CCI.Min_CountryCode = MinCountryName.two_letter_country_code
    AND CCI.Continent_Code = MinCountryName.continent_code
ORDER BY
    CCI.Date, CCI.continent_code;