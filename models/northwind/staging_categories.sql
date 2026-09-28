with source as (

    select * from {{ source('northwind_data', 'categories') }}

),

renamed as (

    select
        category_id::integer            as category_id,
        category_name::varchar(255)     as category_name,
        --	,description
        --	,picture

    from source

)

select * from renamed