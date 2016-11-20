{% from 'gitlab/map.jinja' import gitlab %}

{% set gitlab_configs = ['gitlab_config_gitlab', 'gitlab_config_database'] %}

{% macro file_requisites(states) %}
{%- for state in states %}
- file: {{ state }}
{%- endfor -%}
{% endmacro %}

include:
  - gitlab.pkg
  - gitlab.config
  - gitlab.install
  - gitlab.service

extend:
  gitlab_service:
    service:
      - watch:
        {{ file_requisites(gitlab_configs) | indent(8) }}
      - require:
        {{ file_requisites(gitlab_configs) | indent(8) }}
        - pkg: gitlab_install
  {%- for cfg in gitlab_configs %}
  {{ cfg }}:
    file:
      - require:
        - pkg: gitlab_install
  {%- endfor %}
