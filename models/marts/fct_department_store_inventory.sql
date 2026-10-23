{{
    config(
        materialized='incremental',
        unique_key='movement_id',
        incremental_strategy='delete+insert',
        on_schema_change='sync_all_columns'
    )
}}

/*
    Marts Fact Table: fct_department_store_inventory
    Description: Incremental fact table tracking inventory receipts, floor replenishment,
                 and write-off stock movements across departments.
    Key features:
    1. materialized='incremental' with unique_key='movement_id' to support upserts.
    2. is_incremental() Jinja macro filters only for incoming records whose
       updated_at is strictly greater than the current max(updated_at) in this table.
    3. delete+insert strategy replaces updated movement records cleanly without duplicates.
*/

with source_inventory as (
    select * from {{ ref('stg_department_store__inventory') }}
),

transformed_inventory as (
    select
        movement_id,
        store_id,
        store_name,
        department_name,
        product_id,
        product_name,
        movement_type,
        quantity_change,
        unit_cost,
        total_cost,
        movement_timestamp,
        updated_at,
        current_timestamp as dbt_loaded_at
    from source_inventory

    {% if is_incremental() %}
    -- Incremental watermark filter: only process modified or newly added inventory movements
    where updated_at > (
        select coalesce(max(updated_at), cast('1970-01-01 00:00:00' as timestamp))
        from {{ this }}
    )
    {% endif %}
)

select * from transformed_inventory
