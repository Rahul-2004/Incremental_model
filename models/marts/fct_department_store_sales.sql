{{
    config(
        materialized='incremental',
        unique_key='sale_id',
        incremental_strategy='delete+insert',
        on_schema_change='sync_all_columns'
    )
}}

/*
    Marts Fact Table: fct_department_store_sales
    Description: Department store transaction fact table loaded incrementally.
    Key features:
    1. materialized='incremental' with unique_key='sale_id' to support upserts.
    2. is_incremental() Jinja macro filters only for incoming records whose
       updated_at is strictly greater than the current max(updated_at) in this table.
    3. delete+insert strategy replaces updated records cleanly without duplicate keys.
*/

with source_sales as (
    select * from {{ ref('stg_department_store__sales') }}
),

transformed_sales as (
    select
        sale_id,
        store_id,
        store_name,
        department_name,
        customer_id,
        product_id,
        product_name,
        quantity,
        unit_price,
        gross_amount,
        discount_amount,
        net_amount,
        payment_method,
        sale_timestamp,
        updated_at,
        current_timestamp as dbt_loaded_at
    from source_sales

    {% if is_incremental() %}
    -- Watermark filter: only ingest new or modified sales records
    where updated_at > (
        select coalesce(max(updated_at), cast('1970-01-01 00:00:00' as timestamp))
        from {{ this }}
    )
    {% endif %}
)

select * from transformed_sales
