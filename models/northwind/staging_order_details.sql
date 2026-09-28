with source as (

    select * from {{ source('northwind_data', 'order_details') }}

),

renamed as (

    select
        order_id::integer               as order_id,
        product_id::integer             as product_id,
        unit_price::numeric(12, 2)      as unit_price,
        quantity::integer               as quantity,
        discount::numeric(5, 2)         as discount,

    from source

)

select * from renamed