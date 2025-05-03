{% macro pg_conn_name(project, location, conn_name) %}
    projects/{{ project }}/locations/{{ location }}/connections/{{ conn_name }}
{% endmacro %}