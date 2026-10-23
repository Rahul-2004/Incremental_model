/*
    Staging Model: stg_department_store__inventory
    Description: Simulates department store floor stock & stockroom replenishment/movement events.
                 Generates realistic mock movement records directly via SQL CTEs without seeds.

    Batch simulation:
    - Default (batch = 1): Baseline inventory events from 2026-10-20.
    - Incremental (batch = 2): New inventory receipts from 2026-10-21 + updated audit quantity on 301.
*/

with batch_1_inventory as (
    select
        301 as movement_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Apparel' as department_name,
        'PRD_APP_01' as product_id,
        'Merino Wool Sweater' as product_name,
        'Receipt/Restock' as movement_type,
        40 as quantity_change,
        cast(42.50 as decimal(10, 2)) as unit_cost,
        cast(1700.00 as decimal(10, 2)) as total_cost,
        cast('2026-10-20 08:30:00' as timestamp) as movement_timestamp,
        cast('2026-10-20 08:30:00' as timestamp) as updated_at

    union all

    select
        302 as movement_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Cosmetics' as department_name,
        'PRD_COS_01' as product_id,
        'Hydrating Face Serum' as product_name,
        'Floor Replenishment' as movement_type,
        25 as quantity_change,
        cast(28.00 as decimal(10, 2)) as unit_cost,
        cast(700.00 as decimal(10, 2)) as total_cost,
        cast('2026-10-20 09:15:00' as timestamp) as movement_timestamp,
        cast('2026-10-20 09:15:00' as timestamp) as updated_at

    union all

    select
        303 as movement_id,
        'STORE_02' as store_id,
        'Uptown Galleria' as store_name,
        'Home Goods' as department_name,
        'PRD_HOM_01' as product_id,
        'Cast Iron Dutch Oven' as product_name,
        'Receipt/Restock' as movement_type,
        15 as quantity_change,
        cast(55.00 as decimal(10, 2)) as unit_cost,
        cast(825.00 as decimal(10, 2)) as total_cost,
        cast('2026-10-20 10:00:00' as timestamp) as movement_timestamp,
        cast('2026-10-20 10:00:00' as timestamp) as updated_at

    union all

    select
        304 as movement_id,
        'STORE_02' as store_id,
        'Uptown Galleria' as store_name,
        'Footwear' as department_name,
        'PRD_FTW_01' as product_id,
        'Leather Chelsea Boots' as product_name,
        'Damaged Write-off' as movement_type,
        -1 as quantity_change,
        cast(75.00 as decimal(10, 2)) as unit_cost,
        cast(-75.00 as decimal(10, 2)) as total_cost,
        cast('2026-10-20 14:20:00' as timestamp) as movement_timestamp,
        cast('2026-10-20 14:20:00' as timestamp) as updated_at

    union all

    select
        305 as movement_id,
        'STORE_03' as store_id,
        'Suburban Mall' as store_name,
        'Electronics' as department_name,
        'PRD_ELC_01' as product_id,
        'Noise-Canceling Headphones' as product_name,
        'Receipt/Restock' as movement_type,
        20 as quantity_change,
        cast(130.00 as decimal(10, 2)) as unit_cost,
        cast(2600.00 as decimal(10, 2)) as total_cost,
        cast('2026-10-20 15:45:00' as timestamp) as movement_timestamp,
        cast('2026-10-20 15:45:00' as timestamp) as updated_at
),

batch_2_inventory as (
    -- Updated record: movement 301 audit count corrected (+5 additional units verified)
    select
        301 as movement_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Apparel' as department_name,
        'PRD_APP_01' as product_id,
        'Merino Wool Sweater' as product_name,
        'Receipt/Restock' as movement_type,
        45 as quantity_change,
        cast(42.50 as decimal(10, 2)) as unit_cost,
        cast(1912.50 as decimal(10, 2)) as total_cost,
        cast('2026-10-20 08:30:00' as timestamp) as movement_timestamp,
        cast('2026-10-21 08:00:00' as timestamp) as updated_at

    union all

    -- New movement 306
    select
        306 as movement_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Apparel' as department_name,
        'PRD_APP_02' as product_id,
        'Silk Button-down Shirt' as product_name,
        'Receipt/Restock' as movement_type,
        30 as quantity_change,
        cast(50.00 as decimal(10, 2)) as unit_cost,
        cast(1500.00 as decimal(10, 2)) as total_cost,
        cast('2026-10-21 09:30:00' as timestamp) as movement_timestamp,
        cast('2026-10-21 09:30:00' as timestamp) as updated_at

    union all

    -- New movement 307
    select
        307 as movement_id,
        'STORE_02' as store_id,
        'Uptown Galleria' as store_name,
        'Home Goods' as department_name,
        'PRD_HOM_02' as product_id,
        'Espresso Machine' as product_name,
        'Receipt/Restock' as movement_type,
        10 as quantity_change,
        cast(175.00 as decimal(10, 2)) as unit_cost,
        cast(1750.00 as decimal(10, 2)) as total_cost,
        cast('2026-10-21 11:15:00' as timestamp) as movement_timestamp,
        cast('2026-10-21 11:15:00' as timestamp) as updated_at

    union all

    -- New movement 308
    select
        308 as movement_id,
        'STORE_03' as store_id,
        'Suburban Mall' as store_name,
        'Footwear' as department_name,
        'PRD_FTW_02' as product_id,
        'Performance Running Shoes' as product_name,
        'Customer Return Restock' as movement_type,
        1 as quantity_change,
        cast(65.00 as decimal(10, 2)) as unit_cost,
        cast(65.00 as decimal(10, 2)) as total_cost,
        cast('2026-10-21 14:00:00' as timestamp) as movement_timestamp,
        cast('2026-10-21 14:00:00' as timestamp) as updated_at
),

combined_stream as (
    select * from batch_1_inventory
    {% if var('batch', 1) | int >= 2 %}
    union all
    select * from batch_2_inventory
    {% endif %}
),

deduped_inventory as (
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
        row_number() over (
            partition by movement_id
            order by updated_at desc
        ) as row_num
    from combined_stream
)

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
    updated_at
from deduped_inventory
where row_num = 1
