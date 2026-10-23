/*
    Staging Model: stg_department_store__customer_loyalty
    Description: Simulates department store rewards program transactions (points earn/redeem).
                 Generates realistic mock loyalty records directly via SQL CTEs without seeds.

    Batch simulation:
    - Default (batch = 1): Baseline loyalty transactions from 2026-10-20.
    - Incremental (batch = 2): New loyalty events from 2026-10-21 + promotion bonus adjustment on 401.
*/

with batch_1_loyalty as (
    select
        401 as loyalty_txn_id,
        'CUST_1001' as customer_id,
        101 as sale_id,
        'STORE_01' as store_id,
        'Apparel' as department_name,
        'Gold' as tier_level,
        160 as points_earned,
        0 as points_redeemed,
        cast(0.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-20 10:15:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-20 10:15:00' as timestamp) as updated_at

    union all

    select
        402 as loyalty_txn_id,
        'CUST_1002' as customer_id,
        102 as sale_id,
        'STORE_01' as store_id,
        'Cosmetics' as department_name,
        'Silver' as tier_level,
        65 as points_earned,
        0 as points_redeemed,
        cast(0.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-20 11:30:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-20 11:30:00' as timestamp) as updated_at

    union all

    select
        403 as loyalty_txn_id,
        'CUST_1003' as customer_id,
        103 as sale_id,
        'STORE_02' as store_id,
        'Home Goods' as department_name,
        'Platinum' as tier_level,
        210 as points_earned,
        100 as points_redeemed,
        cast(10.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-20 13:45:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-20 13:45:00' as timestamp) as updated_at

    union all

    select
        404 as loyalty_txn_id,
        'CUST_1004' as customer_id,
        104 as sale_id,
        'STORE_02' as store_id,
        'Footwear' as department_name,
        'Classic' as tier_level,
        130 as points_earned,
        0 as points_redeemed,
        cast(0.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-20 15:20:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-20 15:20:00' as timestamp) as updated_at

    union all

    select
        405 as loyalty_txn_id,
        'CUST_1005' as customer_id,
        105 as sale_id,
        'STORE_03' as store_id,
        'Electronics' as department_name,
        'Platinum' as tier_level,
        440 as points_earned,
        200 as points_redeemed,
        cast(20.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-20 16:50:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-20 16:50:00' as timestamp) as updated_at
),

batch_2_loyalty as (
    -- Updated record: loyalty txn 401 received 50 bonus promotional points
    select
        401 as loyalty_txn_id,
        'CUST_1001' as customer_id,
        101 as sale_id,
        'STORE_01' as store_id,
        'Apparel' as department_name,
        'Gold' as tier_level,
        210 as points_earned,
        0 as points_redeemed,
        cast(0.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-20 10:15:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-21 09:00:00' as timestamp) as updated_at

    union all

    -- New loyalty txn 406
    select
        406 as loyalty_txn_id,
        'CUST_1007' as customer_id,
        107 as sale_id,
        'STORE_01' as store_id,
        'Apparel' as department_name,
        'Silver' as tier_level,
        100 as points_earned,
        0 as points_redeemed,
        cast(0.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-21 11:00:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-21 11:00:00' as timestamp) as updated_at

    union all

    -- New loyalty txn 407
    select
        407 as loyalty_txn_id,
        'CUST_1008' as customer_id,
        108 as sale_id,
        'STORE_02' as store_id,
        'Home Goods' as department_name,
        'Platinum' as tier_level,
        600 as points_earned,
        300 as points_redeemed,
        cast(30.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-21 14:15:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-21 14:15:00' as timestamp) as updated_at

    union all

    -- New loyalty txn 408
    select
        408 as loyalty_txn_id,
        'CUST_1009' as customer_id,
        109 as sale_id,
        'STORE_03' as store_id,
        'Footwear' as department_name,
        'Gold' as tier_level,
        240 as points_earned,
        0 as points_redeemed,
        cast(0.00 as decimal(10, 2)) as reward_discount_amount,
        cast('2026-10-21 16:30:00' as timestamp) as loyalty_timestamp,
        cast('2026-10-21 16:30:00' as timestamp) as updated_at
),

combined_stream as (
    select * from batch_1_loyalty
    {% if var('batch', 1) | int >= 2 %}
    union all
    select * from batch_2_loyalty
    {% endif %}
),

deduped_loyalty as (
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
        row_number() over (
            partition by loyalty_txn_id
            order by updated_at desc
        ) as row_num
    from combined_stream
)

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
    updated_at
from deduped_loyalty
where row_num = 1
