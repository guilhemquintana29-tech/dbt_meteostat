WITH departure_stats AS (

    SELECT
        origin,

        COUNT(DISTINCT dest) AS unique_departure_connections,

        COUNT(*) AS planned_departures,

        COUNT(*) FILTER (
            WHERE cancelled = 1
        ) AS cancelled_departures,

        COUNT(*) FILTER (
            WHERE diverted = 1
        ) AS diverted_departures,

        COUNT(*) FILTER (
            WHERE cancelled = 0
        ) AS actual_departures

    FROM {{ ref('prep_flights') }}

    GROUP BY origin

),

arrival_stats AS (

    SELECT
        dest,

        COUNT(DISTINCT origin) AS unique_arrival_connections,

        COUNT(*) AS planned_arrivals,

        COUNT(*) FILTER (
            WHERE cancelled = 1
        ) AS cancelled_arrivals,

        COUNT(*) FILTER (
            WHERE diverted = 1
        ) AS diverted_arrivals,

        COUNT(*) FILTER (
            WHERE cancelled = 0
        ) AS actual_arrivals

    FROM {{ ref('prep_flights') }}

    GROUP BY dest

)

select pa.faa, pa.city, pa.country, pa.name, unique_departure_connections, planned_departures, diverted_departures, actual_departures, unique_arrival_connections, planned_arrivals, cancelled_arrivals, diverted_arrivals, actual_arrivals
FROM departure_stats d

FULL OUTER JOIN arrival_stats a
    ON d.origin = a.dest

LEFT JOIN {{ ref('prep_airports') }} pa
    ON COALESCE(d.origin, a.dest) = pa.faa