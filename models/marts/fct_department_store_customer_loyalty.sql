{{
    config(
        materialized='incremental',
        unique_key='loyalty_txn_id',
        incremental_strategy='delete+insert',
        on_schema_change='sync_all_columns'
    )
}}

/*
    Marts Fact Table: fct_department_store_customer_loyalty
    Description: Incremental fact table tracking department store customer loyalty points & tier activity.
    Key features:
    1. materialized='incremental' with unique_key='loyalty_txn_id' to support upserts.
    2. is_incremental() Jinja macro filters only for incoming records whose
       updated_at is strictly greater than the current max(updated_at) in this table.
    3. delete+insert strategy updates loyalty rewards adjustments cleanly without duplicates.
*/

with source_loyalty as (
    select * from {{ ref('stg_department_store__customer_loyalty') }}
),

transformed_loyalty as (
    select
        loyalty_txn_id,
        customer_id,
        sale_id,
        store_id,
        department_name,
        tier_level,
        points_earned,
        points_redeemed,
        reward_discount_amount,
        loyalty_timestamp,
        updated_at,
        current_timestamp as dbt_loaded_at
    from source_loyalty

    {% if is_incremental() %}
    -- Incremental watermark filter: only process modified or newly added loyalty transactions
    where updated_at > (
        select coalesce(max(updated_at), cast('1970-01-01 00:00:00' as timestamp))
        from {{ this }}
    )
    {% endif %}
)

select * from transformed_loyalty
