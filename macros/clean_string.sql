-- Reusable macro for standardizing string columns
-- Usage: {{ clean_string('column_name', 'DEFAULT') }}

{% macro clean_string(column_name, default_value='UNKNOWN') %}
    UPPER(TRIM(COALESCE({{ column_name }}, '{{ default_value }}')))
{% endmacro %}


-- Reusable macro for cleaning names
-- Bobby JacksOn → Bobby Jackson

{% macro clean_name(column_name) %}
    INITCAP(TRIM(COALESCE({{ column_name }}, 'Unknown')))
{% endmacro %}