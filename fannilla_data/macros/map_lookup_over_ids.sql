{% macro map_pg_lookup_over_ids(column_name, pg_connection, lookup_table, id_field='id', label_field='name') %}
    (
        CASE
            {% set query %}
                SELECT *
                FROM EXTERNAL_QUERY(
                'projects/{{ var('gcp_project') }}
                /locations/{{ var('location') }}
                /connections/{{ pg_connection }}',
                'SELECT 
                {{ id_field }}, 
                {{ label_field }} 
                FROM {{ lookup_table }})'
                )
            {% endset %}

            {% for row in dbt_utils.get_query_results_as_dict(query) %}
                WHEN {{ column_name }} = {{ row[id_field] }} THEN '{{ row[label_field] }}'
            {% endfor %}
            ELSE 'Unknown'
        END
    )
{% endmacro %}