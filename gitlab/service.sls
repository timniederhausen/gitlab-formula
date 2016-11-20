{% from 'gitlab/map.jinja' import gitlab with context %}

{% set service_function = 'running' if gitlab.service_enabled else 'dead' %}

gitlab_service:
  service.{{ service_function }}:
    - name: {{ gitlab.service }}
    - enable: {{ gitlab.service_enabled }}
