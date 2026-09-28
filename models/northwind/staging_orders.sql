with source as (

    select * from {{ source('northwind_data', 'orders') }}

),

renamed as (

    select
        order_id::integer                   as order_id,
        customer_id::varchar(20)            as customer_id,
        employee_id::integer                as employee_id,
        order_date::date                    as order_date,
        required_date::date                 as required_date,
        shipped_date::date                  as shipped_date,
        ship_via::integer                   as shipper_id,
        freight::numeric(12, 2)             as freight,
        ship_name::varchar(50)              as ship_name,
        ship_address::varchar(50)           as ship_address,
        ship_city::varchar(50)              as ship_city,
        ship_region::varchar(50)            as ship_region,
        ship_postal_code::varchar(20)       as ship_postal_code,
        ship_country::varchar(20)           as ship_country

    from source

)

select * from renamed