/*
    Staging Model: stg_department_store__returns
    Description: Simulates department store customer returns and refund events.
                 Generates realistic mock data directly via SQL CTEs without seeds.

    Batch simulation:
    - Default (batch = 1): Baseline customer returns from 2026-10-20.
    - Incremental (batch = 2): New returns from 2026-10-21 + updated status on return 201.
*/

with batch_1_returns as (
    select
        201 as return_id,
        101 as sale_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Apparel' as department_name,
        'CUST_1001' as customer_id,
        'PRD_APP_01' as product_id,
        'Merino Wool Sweater' as product_name,
        1 as return_quantity,
        cast(80.00 as decimal(10, 2)) as refund_amount,
        'Size/Fit Issue' as return_reason,
        'Pending Inspection' as restock_status,
        cast('2026-10-20 14:00:00' as timestamp) as return_timestamp,
        cast('2026-10-20 14:00:00' as timestamp) as updated_at

    union all

    select
        202 as return_id,
        103 as sale_id,
        'STORE_02' as store_id,
        'Uptown Galleria' as store_name,
        'Home Goods' as department_name,
        'CUST_1003' as customer_id,
        'PRD_HOM_01' as product_id,
        'Cast Iron Dutch Oven' as product_name,
        1 as return_quantity,
        cast(105.00 as decimal(10, 2)) as refund_amount,
        'Color Mismatch' as return_reason,
        'Restocked' as restock_status,
        cast('2026-10-20 16:30:00' as timestamp) as return_timestamp,
        cast('2026-10-20 16:30:00' as timestamp) as updated_at

    union all

    select
        203 as return_id,
        104 as sale_id,
        'STORE_02' as store_id,
        'Uptown Galleria' as store_name,
        'Footwear' as department_name,
        'CUST_1004' as customer_id,
        'PRD_FTW_01' as product_id,
        'Leather Chelsea Boots' as product_name,
        1 as return_quantity,
        cast(130.00 as decimal(10, 2)) as refund_amount,
        'Changed Mind' as return_reason,
        'Restocked' as restock_status,
        cast('2026-10-20 17:15:00' as timestamp) as return_timestamp,
        cast('2026-10-20 17:15:00' as timestamp) as updated_at

    union all

    select
        204 as return_id,
        105 as sale_id,
        'STORE_03' as store_id,
        'Suburban Mall' as store_name,
        'Electronics' as department_name,
        'CUST_1005' as customer_id,
        'PRD_ELC_01' as product_id,
        'Noise-Canceling Headphones' as product_name,
        1 as return_quantity,
        cast(219.99 as decimal(10, 2)) as refund_amount,
        'Defective Item' as return_reason,
        'Returned to Vendor' as restock_status,
        cast('2026-10-20 18:10:00' as timestamp) as return_timestamp,
        cast('2026-10-20 18:10:00' as timestamp) as updated_at
),

batch_2_returns as (
    -- Updated record: return 201 inspected and approved for restocking
    select
        201 as return_id,
        101 as sale_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Apparel' as department_name,
        'CUST_1001' as customer_id,
        'PRD_APP_01' as product_id,
        'Merino Wool Sweater' as product_name,
        1 as return_quantity,
        cast(80.00 as decimal(10, 2)) as refund_amount,
        'Size/Fit Issue' as return_reason,
        'Restocked' as restock_status,
        cast('2026-10-20 14:00:00' as timestamp) as return_timestamp,
        cast('2026-10-21 10:00:00' as timestamp) as updated_at

    union all

    -- New return 205
    select
        205 as return_id,
        107 as sale_id,
        'STORE_01' as store_id,
        'Downtown Flagship' as store_name,
        'Apparel' as department_name,
        'CUST_1007' as customer_id,
        'PRD_APP_02' as product_id,
        'Silk Button-down Shirt' as product_name,
        1 as return_quantity,
        cast(100.00 as decimal(10, 2)) as refund_amount,
        'Gift Return' as return_reason,
        'Restocked' as restock_status,
        cast('2026-10-21 12:45:00' as timestamp) as return_timestamp,
        cast('2026-10-21 12:45:00' as timestamp) as updated_at

    union all

    -- New return 206
    select
        206 as return_id,
        106 as sale_id,
        'STORE_03' as store_id,
        'Suburban Mall' as store_name,
        'Jewelry' as department_name,
        'CUST_1006' as customer_id,
        'PRD_JWL_01' as product_id,
        'Sterling Silver Bracelet' as product_name,
        1 as return_quantity,
        cast(95.00 as decimal(10, 2)) as refund_amount,
        'Changed Mind' as return_reason,
        'Restocked' as restock_status,
        cast('2026-10-21 15:20:00' as timestamp) as return_timestamp,
        cast('2026-10-21 15:20:00' as timestamp) as updated_at
),

combined_stream as (
    select * from batch_1_returns
    {% if var('batch', 1) | int >= 2 %}
    union all
    select * from batch_2_returns
    {% endif %}
),

deduped_returns as (
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
        row_number() over (
            partition by return_id
            order by updated_at desc
        ) as row_num
    from combined_stream
)

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
    updated_at
from deduped_returns
where row_num = 1
