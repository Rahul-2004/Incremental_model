# Department Store Data Mart — 4 Incremental Models in dbt

A production-grade, self-contained dbt project demonstrating **4 distinct incremental models** for a **department store** without relying on any external seeds or CSV files. 

Raw transactional events are simulated directly within SQL CTEs in the staging layer and loaded incrementally into 4 facts in the marts layer using high-watermark tracking and upsert (`delete+insert`) strategies.

---

## Architecture & Project Structure

```text
Incremental_model/
├── dbt_project.yml
├── profiles.yml
├── README.md
└── models/
    ├── staging/
    │   ├── stg_department_store__sales.sql             # Staging view: retail sales events
    │   ├── stg_department_store__returns.sql           # Staging view: customer returns & refunds
    │   ├── stg_department_store__inventory.sql         # Staging view: stock receipts & adjustments
    │   ├── stg_department_store__customer_loyalty.sql  # Staging view: loyalty rewards transactions
    │   └── schema.yml                                  # Staging definitions and generic tests
    └── marts/
        ├── fct_department_store_sales.sql              # Incremental Fact: Sales transactions
        ├── fct_department_store_returns.sql            # Incremental Fact: Returns & refunds
        ├── fct_department_store_inventory.sql          # Incremental Fact: Stock movements
        ├── fct_department_store_customer_loyalty.sql   # Incremental Fact: Rewards activity
        └── schema.yml                                  # Marts definitions and generic tests
```

---

## The 4 Incremental Models

| Model Name | Granularity | Unique Key | Incremental Watermark | Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **`fct_department_store_sales`** | One row per sale transaction | `sale_id` | `updated_at > max(updated_at)` | `delete+insert` |
| **`fct_department_store_returns`** | One row per customer return event | `return_id` | `updated_at > max(updated_at)` | `delete+insert` |
| **`fct_department_store_inventory`** | One row per stock receipt/adjustment | `movement_id` | `updated_at > max(updated_at)` | `delete+insert` |
| **`fct_department_store_customer_loyalty`**| One row per loyalty reward transaction | `loyalty_txn_id` | `updated_at > max(updated_at)` | `delete+insert` |

---

## Incremental Pattern Implemented

Each marts model implements the standard dbt incremental watermark pattern:

```sql
{{
    config(
        materialized='incremental',
        unique_key='<primary_key>',
        incremental_strategy='delete+insert',
        on_schema_change='sync_all_columns'
    )
}}

with source_data as (
    select * from {{ ref('stg_department_store__...') }}
),

transformed as (
    select
        *,
        current_timestamp as dbt_loaded_at
    from source_data

    {% if is_incremental() %}
    -- Ingest only rows newer than the current high-watermark in this table
    where updated_at > (
        select coalesce(max(updated_at), cast('1970-01-01 00:00:00' as timestamp))
        from {{ this }}
    )
    {% endif %}
)

select * from transformed
```

---

## Batch Ingestion & Upsert Simulation (No Seeds Required)

The staging models simulate streaming batches of department store transactions across departments (`Apparel`, `Cosmetics`, `Home Goods`, `Footwear`, `Electronics`, `Jewelry`):

- **Batch 1 (Baseline)**: Initial dataset across all 4 domains.
- **Batch 2 (Incremental Stream)**: New records plus modified records (e.g. sale quantity change, return inspection status approval, inventory count audit adjustment, loyalty promotion bonus).

---

## Step-by-Step Execution Guide

### 1. Initial Load (Batch 1)
Build all 4 staging views and 4 incremental fact tables:
```bash
dbt run
```
Run data tests (78 tests: uniqueness, non-null constraints, and accepted values):
```bash
dbt test
```

### 2. Simulate No-Op Run
Run again without new data:
```bash
dbt run
```
*Result: 0 new rows processed; tables maintain current row counts.*

### 3. Incremental Load (Batch 2)
Simulate newly arrived transactions and record modifications:
```bash
dbt run --vars '{"batch": 2}'
```
*Result:*
- New records are appended across all 4 models.
- Modified records (`sale_id=102`, `return_id=201`, `movement_id=301`, `loyalty_txn_id=401`) are updated in-place without duplicate keys.

Verify tests across updated tables:
```bash
dbt test --vars '{"batch": 2}'
```

### 4. Full Refresh Rebuild
To rebuild all tables from scratch:
```bash
dbt run --full-refresh
```
