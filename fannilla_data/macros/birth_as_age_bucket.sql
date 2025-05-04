{% macro birth_as_age_bucket(date_of_birth, lower, upper) %}
WHEN EXTRACT(YEAR FROM CURRENT_DATE()) - EXTRACT(YEAR FROM date_of_birth) 
BETWEEN lower AND upper THEN '{{ lower }}-{{ upper }}'
{% endmacro %}