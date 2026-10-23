{{
    config(
        materialized='incremental',
        unique_key='return_id',
        incremental_strategy='delete+insert',
        on_schema_change='sync_all_columns'
    )
}}

/*
    Marts Fact Table: fct_department_store_returns
    Description: Incremental fact table capturing customer returns, refunds, and restock status.
    Key features:
    1. materialized='incremental' with unique_key='return_id' to support upserts.
    2. is_incremental() Jinja macro filters only for incoming records whose
       updated_at is strictly greater than the current max(updated_at) in this table.
    3. delete+insert strategy replaces updated return status cleanly without duplicates.
*/

with source_returns as (
    select * from {{ ref('stg_department_store__returns') }}
),

transformed_returns as (
    select
        return_id,
        sale_id,
        store_id,
        store_name,
        department_name,
        customer_id,
        product_id,
        product_name,
        return_quantity,
        refund_amount,
        return_reason,
        restock_status,
        return_timestamp,
        updated_at,
        current_timestamp as dbt_loaded_at
    from source_returns

    {% if is_incremental() %}
    -- Incremental watermark filter: only process modified or newly added returns
    where updated_at > (
        select coalesce(max(updated_at), cast('1970-01-01 00:00:00' as timestamp))
        from {{ this }}
    )
    {% endif %}
)

select * from transformed_returns
