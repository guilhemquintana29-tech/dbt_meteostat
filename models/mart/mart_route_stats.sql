WITH route_stats AS (
    SELECT
        origin,
        dest,
        COUNT(*) AS total_flights,
        COUNT(DISTINCT tail_number) AS unique_airplanes,
        COUNT(DISTINCT airline) AS unique_airlines,
        AVG(actual_elapsed_time) AS avg_actual_elapsed_time,
        AVG(arr_delay) AS avg_arr_delay,
        MAX(arr_delay) AS max_arr_delay,
        MIN(arr_delay) AS min_arr_delay,
        COUNT(*) FILTER (WHERE cancelled = 1) AS total_cancelled,
        COUNT(*) FILTER (WHERE diverted = 1) AS total_diverted
    FROM {{ ref('prep_flights') }}
    GROUP BY origin, dest
)
SELECT
    r.origin,
    r.dest,
    r.total_flights,
    r.unique_airplanes,
    r.unique_airlines,
    r.avg_actual_elapsed_time,
    r.avg_arr_delay,
    r.max_arr_delay,
    r.min_arr_delay,
    r.total_cancelled,
    r.total_diverted,
    oa.city AS origin_city,
    oa.country AS origin_country,
    oa.name AS origin_name,
    da.city AS destination_city,
    da.country AS destination_country,
    da.name AS destination_name
FROM route_stats AS r
LEFT JOIN {{ ref('prep_airports') }} AS oa
    ON r.origin = oa.faa
LEFT JOIN {{ ref('prep_airports') }} AS da
    ON r.dest = da.faa