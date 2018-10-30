{% from 'gitlab/map.jinja' import gitlab, configs %}

include:
  - gitlab.install
  - gitlab.service

extend:
  gitlab_service:
    service:
      - require:
        - cmd: gitlab_setup
  {%- for name in configs.keys() %}
  gitlab_config_{{ name }}:
    file:
      - watch_in:
        - service: gitlab_service
      - require_in:
        - service: gitlab_service
  {%- endfor %}
