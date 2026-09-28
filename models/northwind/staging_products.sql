with source as (

    select * from {{ source('northwind_data', 'products') }}

),

renamed as (

    select
        product_id::integer                 as product_id,
        product_name::varchar(100)          as product_name,
        supplier_id::integer                as supplier_id,
        category_id::integer                as category_id,
        quantity_per_unit::varchar(255)     as quantity_per_unit,
        unit_price::numeric(12, 2)          as unit_price,
        units_in_stock::integer             as units_in_stock,
        units_on_order::integer             as units_on_order,
        reorder_level::integer              as reorder_level,
        discontinued::boolean               as is_discontinued

    from source

)

select * from renamed