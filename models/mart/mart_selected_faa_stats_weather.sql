WITH origin_stats AS (
    SELECT
        origin AS faa,
        flight_date,
        COUNT(DISTINCT dest) AS unique_departure_connections,
        COUNT(*) AS dep_planned,
        COUNT(*) FILTER (WHERE cancelled = 1) AS dep_cancelled,
        COUNT(*) FILTER (WHERE diverted = 1) AS dep_diverted,
        COUNT(*) FILTER (WHERE cancelled = 0) AS dep_occurred
    FROM {{ ref('prep_flights') }}
    GROUP BY origin, flight_date
),

dest_stats AS (
    SELECT
        dest AS faa,
        flight_date,
        COUNT(DISTINCT origin) AS unique_arrival_connections,
        COUNT(*) AS arr_planned,
        COUNT(*) FILTER (WHERE cancelled = 1) AS arr_cancelled,
        COUNT(*) FILTER (WHERE diverted = 1) AS arr_diverted,
        COUNT(*) FILTER (WHERE cancelled = 0) AS arr_occurred
    FROM {{ ref('prep_flights') }}
    GROUP BY dest, flight_date
),

daily_activity AS (
    SELECT
        faa,
        flight_date,
        COUNT(DISTINCT tail_number) AS unique_airplanes,
        COUNT(DISTINCT airline) AS unique_airlines
    FROM (
        SELECT origin AS faa, flight_date, tail_number, airline
        FROM {{ ref('prep_flights') }}
        UNION ALL
        SELECT dest AS faa, flight_date, tail_number, airline
        FROM {{ ref('prep_flights') }}
    ) AS movements
    GROUP BY faa, flight_date
)

SELECT
    w.airport_code AS faa,
    w.reading_date AS flight_date,
    a.name,
    a.city,
    a.country,
    os.unique_departure_connections,
    ds.unique_arrival_connections,
    COALESCE(os.dep_planned, 0)   + COALESCE(ds.arr_planned, 0)   AS total_planned,
    COALESCE(os.dep_cancelled, 0) + COALESCE(ds.arr_cancelled, 0) AS total_cancelled,
    COALESCE(os.dep_diverted, 0)  + COALESCE(ds.arr_diverted, 0)  AS total_diverted,
    COALESCE(os.dep_occurred, 0)  + COALESCE(ds.arr_occurred, 0)  AS total_occurred,
    da.unique_airplanes,
    da.unique_airlines,
    w.min_temp_c            AS min_temp,
    w.max_temp_c            AS max_temp,
    w.precipitation_mm      AS precipitation,
    w.max_snow_mm           AS snow_fall,
    w.avg_wind_direction,
    w.avg_wind_speed_kmh    AS avg_wind_speed,
    w.wind_peakgust_kmh     AS wind_peak_gust
FROM {{ ref('prep_weather_daily') }} AS w
LEFT JOIN origin_stats AS os
    ON w.airport_code = os.faa AND w.reading_date = os.flight_date
LEFT JOIN dest_stats AS ds
    ON w.airport_code = ds.faa AND w.reading_date = ds.flight_date
LEFT JOIN daily_activity AS da
    ON w.airport_code = da.faa AND w.reading_date = da.flight_date
LEFT JOIN {{ ref('prep_airports') }} AS a
    ON w.airport_code = a.faa