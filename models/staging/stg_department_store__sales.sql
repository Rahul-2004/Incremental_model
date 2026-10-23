/*
    Staging Model: stg_department_store__sales
    Description: Simulates raw transactional sales events for a department store chain.
                 Generates realistic transaction data directly via SQL CTEs without relying
                 on external seeds or files.

    Batch simulation:
    - Default (batch = 1): Yields initial baseline transactions.
    - Incremental (batch = 2): Yields new transactions plus an updated record
      to demonstrate incremental ingestion and upsert (insert + update).
*/

with batch_1_sales as (
    select
        101 as sale_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Apparel' as department_name,
        'CUST_1001' as customer_id,
        'PRD_APP_01' as product_id,
        'Merino Wool Sweater' as product_name,
        2 as quantity,
        cast(85.00 as decimal(10, 2)) as unit_price,
        cast(170.00 as decimal(10, 2)) as gross_amount,
        cast(10.00 as decimal(10, 2)) as discount_amount,
        cast(160.00 as decimal(10, 2)) as net_amount,
        'Credit Card' as payment_method,
        cast('2026-10-20 10:15:00' as timestamp) as sale_timestamp,
        cast('2026-10-20 10:15:00' as timestamp) as updated_at

    union all

    select
        102 as sale_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Cosmetics' as department_name,
        'CUST_1002' as customer_id,
        'PRD_COS_01' as product_id,
        'Hydrating Face Serum' as product_name,
        1 as quantity,
        cast(65.00 as decimal(10, 2)) as unit_price,
        cast(65.00 as decimal(10, 2)) as gross_amount,
        cast(0.00 as decimal(10, 2)) as discount_amount,
        cast(65.00 as decimal(10, 2)) as net_amount,
        'Mobile Payment' as payment_method,
        cast('2026-10-20 11:30:00' as timestamp) as sale_timestamp,
        cast('2026-10-20 11:30:00' as timestamp) as updated_at

    union all

    select
        103 as sale_id,
        'STORE_02' as store_id,
        'Uptown Galleria' as store_name,
        'Home Goods' as department_name,
        'CUST_1003' as customer_id,
        'PRD_HOM_01' as product_id,
        'Cast Iron Dutch Oven' as product_name,
        1 as quantity,
        cast(120.00 as decimal(10, 2)) as unit_price,
        cast(120.00 as decimal(10, 2)) as gross_amount,
        cast(15.00 as decimal(10, 2)) as discount_amount,
        cast(105.00 as decimal(10, 2)) as net_amount,
        'Credit Card' as payment_method,
        cast('2026-10-20 13:45:00' as timestamp) as sale_timestamp,
        cast('2026-10-20 13:45:00' as timestamp) as updated_at

    union all

    select
        104 as sale_id,
        'STORE_02' as store_id,
        'Uptown Galleria' as store_name,
        'Footwear' as department_name,
        'CUST_1004' as customer_id,
        'PRD_FTW_01' as product_id,
        'Leather Chelsea Boots' as product_name,
        1 as quantity,
        cast(150.00 as decimal(10, 2)) as unit_price,
        cast(150.00 as decimal(10, 2)) as gross_amount,
        cast(20.00 as decimal(10, 2)) as discount_amount,
        cast(130.00 as decimal(10, 2)) as net_amount,
        'Debit Card' as payment_method,
        cast('2026-10-20 15:20:00' as timestamp) as sale_timestamp,
        cast('2026-10-20 15:20:00' as timestamp) as updated_at

    union all

    select
        105 as sale_id,
        'STORE_03' as store_id,
        'Suburban Mall' as store_name,
        'Electronics' as department_name,
        'CUST_1005' as customer_id,
        'PRD_ELC_01' as product_id,
        'Noise-Canceling Headphones' as product_name,
        1 as quantity,
        cast(249.99 as decimal(10, 2)) as unit_price,
        cast(249.99 as decimal(10, 2)) as gross_amount,
        cast(30.00 as decimal(10, 2)) as discount_amount,
        cast(219.99 as decimal(10, 2)) as net_amount,
        'Credit Card' as payment_method,
        cast('2026-10-20 16:50:00' as timestamp) as sale_timestamp,
        cast('2026-10-20 16:50:00' as timestamp) as updated_at

    union all

    select
        106 as sale_id,
        'STORE_03' as store_id,
        'Suburban Mall' as store_name,
        'Jewelry' as department_name,
        'CUST_1006' as customer_id,
        'PRD_JWL_01' as product_id,
        'Sterling Silver Bracelet' as product_name,
        1 as quantity,
        cast(95.00 as decimal(10, 2)) as unit_price,
        cast(95.00 as decimal(10, 2)) as gross_amount,
        cast(0.00 as decimal(10, 2)) as discount_amount,
        cast(95.00 as decimal(10, 2)) as net_amount,
        'Gift Card' as payment_method,
        cast('2026-10-20 17:40:00' as timestamp) as sale_timestamp,
        cast('2026-10-20 17:40:00' as timestamp) as updated_at
),

batch_2_sales as (
    -- Updated record: sale_id 102 updated on next day (quantity changed to 2, discount added)
    select
        102 as sale_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Cosmetics' as department_name,
        'CUST_1002' as customer_id,
        'PRD_COS_01' as product_id,
        'Hydrating Face Serum' as product_name,
        2 as quantity,
        cast(65.00 as decimal(10, 2)) as unit_price,
        cast(130.00 as decimal(10, 2)) as gross_amount,
        cast(15.00 as decimal(10, 2)) as discount_amount,
        cast(115.00 as decimal(10, 2)) as net_amount,
        'Mobile Payment' as payment_method,
        cast('2026-10-20 11:30:00' as timestamp) as sale_timestamp,
        cast('2026-10-21 09:15:00' as timestamp) as updated_at

    union all

    -- New sale 107
    select
        107 as sale_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Apparel' as department_name,
        'CUST_1007' as customer_id,
        'PRD_APP_02' as product_id,
        'Silk Button-down Shirt' as product_name,
        1 as quantity,
        cast(110.00 as decimal(10, 2)) as unit_price,
        cast(110.00 as decimal(10, 2)) as gross_amount,
        cast(10.00 as decimal(10, 2)) as discount_amount,
        cast(100.00 as decimal(10, 2)) as net_amount,
        'Credit Card' as payment_method,
        cast('2026-10-21 11:00:00' as timestamp) as sale_timestamp,
        cast('2026-10-21 11:00:00' as timestamp) as updated_at

    union all

    -- New sale 108
    select
        108 as sale_id,
        'STORE_02' as store_id,
        'Uptown Galleria' as store_name,
        'Home Goods' as department_name,
        'CUST_1008' as customer_id,
        'PRD_HOM_02' as product_id,
        'Espresso Machine' as product_name,
        1 as quantity,
        cast(350.00 as decimal(10, 2)) as unit_price,
        cast(350.00 as decimal(10, 2)) as gross_amount,
        cast(50.00 as decimal(10, 2)) as discount_amount,
        cast(300.00 as decimal(10, 2)) as net_amount,
        'Credit Card' as payment_method,
        cast('2026-10-21 14:15:00' as timestamp) as sale_timestamp,
        cast('2026-10-21 14:15:00' as timestamp) as updated_at

    union all

    -- New sale 109
    select
        109 as sale_id,
        'STORE_03' as store_id,
        'Suburban Mall' as store_name,
        'Footwear' as department_name,
        'CUST_1009' as customer_id,
        'PRD_FTW_02' as product_id,
        'Performance Running Shoes' as product_name,
        2 as quantity,
        cast(130.00 as decimal(10, 2)) as unit_price,
        cast(260.00 as decimal(10, 2)) as gross_amount,
        cast(20.00 as decimal(10, 2)) as discount_amount,
        cast(240.00 as decimal(10, 2)) as net_amount,
        'Debit Card' as payment_method,
        cast('2026-10-21 16:30:00' as timestamp) as sale_timestamp,
        cast('2026-10-21 16:30:00' as timestamp) as updated_at
),

combined_stream as (
    select * from batch_1_sales
    {% if var('batch', 1) | int >= 2 %}
    union all
    select * from batch_2_sales
    {% endif %}
),

-- Deduplicate to get the latest state per sale_id (standard CDC/staging practice)
deduped_sales as (
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
        row_number() over (
            partition by sale_id
            order by updated_at desc
        ) as row_num
    from combined_stream
)

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
    updated_at
from deduped_sales
where row_num = 1
