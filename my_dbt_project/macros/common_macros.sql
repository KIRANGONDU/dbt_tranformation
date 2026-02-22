{% macro generate_alias_name(custom_alias_name=none, node=none) -%}
    {#
    ============================================================================
    MACRO: generate_alias_name
    ============================================================================
    
    PURPOSE:
      - Override default table/view naming behavior
      - Create custom naming convention for models
      - Automatically add prefixes based on materialization
      
    USAGE IN MODEL CONFIG:
      config(
        materialized = 'view',
        alias = generate_alias_name(custom_alias_name='my_view_name')
      )
    
    ============================================================================
    #}
    
    {%- if custom_alias_name is none -%}
        {{ node.name }}
    {%- else -%}
        {{ custom_alias_name | replace(' ','_') | lower }}
    {%- endif -%}
{%- endmacro %}


{% macro insert_metrics(table_name) -%}
    {#
    ============================================================================
    MACRO: insert_metrics
    ============================================================================
    
    PURPOSE:
      - Post-processing hook to log table statistics
      - Called after model is built (in post_hook)
      - Logs row count, columns, build duration
      
    PARAMETERS:
      - table_name: Name of the table to analyze
      
    USAGE IN MODEL:
      config(
        post_hook = "{{ insert_metrics(table_name=this.name) }}"
      )
    
    ============================================================================
    #}
    
    {% if execute %}
        -- This code runs after the model is successfully built
        {% set columns = run_query('select * from ' ~ table_name ~ ' limit 1') %}
        {% set row_count = run_query('select count(*) as cnt from ' ~ table_name) %}
        
        -- Log metrics (visible in dbt logs)
        {{ log("✓ Metrics for " ~ table_name ~ ":", info=true) }}
        {{ log("  - Rows: " ~ row_count[0][0], info=true) }}
        {{ log("  - Columns: " ~ columns.columns | length, info=true) }}
    {% endif %}
{%- endmacro %}


{% macro cents_to_dollars(amount_cents) -%}
    {#
    ============================================================================
    MACRO: cents_to_dollars
    ============================================================================
    
    PURPOSE:
      - Convert cents to dollars (divide by 100)
      - Useful for consistent currency handling
      - Reusable in multiple models
      
    PARAMETERS:
      - amount_cents: Column or value in cents
      
    USAGE:
      select 
        {{ cents_to_dollars('amount_cents') }} as amount_dollars
      from my_table
      
    GENERATED SQL:
      select 
        (amount_cents / 100) as amount_dollars
      from my_table
    
    ============================================================================
    #}
    ({{ amount_cents }} / 100)
{%- endmacro %}


{% macro get_date_boundaries(date_col, interval_days) -%}
    {#
    ============================================================================
    MACRO: get_date_boundaries
    ============================================================================
    
    PURPOSE:
      - Calculate rolling date window boundaries
      - Support "last N days" filters
      - Create consistent date range logic
      
    PARAMETERS:
      - date_col: Date column reference
      - interval_days: Number of days in window
      
    USAGE:
      select * from orders
      where {{ get_date_boundaries('order_date', 30) }}
      
    ============================================================================
    #}
    {{ date_col }} >= current_date - {{ interval_days }}
    and {{ date_col }} < current_date
{%- endmacro %}
