{% from 'gitlab/map.jinja' import gitlab with context %}

{% set gitlab_configs = ['gitlab_config'] %}

gitlab_user:
  user.present:
    - name: {{ gitlab.user }}
    - groups:
      - redis

gitlab_group:
  group.present:
    - name: {{ gitlab.group }}

{% set configs = {
  'gitlab': 'config',
  'database': 'database',
} %}

{% for name, value in configs.items() %}
gitlab_config_{{ name }}:
  file.serialize:
    - name: {{ gitlab.directory }}/config/{{ name }}.yml
    - dataset: {{ gitlab[value] | yaml }}
    - formatter: yaml
    - user: {{ gitlab.user }}
    - group: {{ gitlab.group }}
    - create: false
    - merge_if_exists: true
{% endfor %}

{% for name, value in gitlab.git_config.items() %}
gitlab_git_cfg_{{ name }}:
  git.config_set:
    - name: {{ name | yaml_encode }}
    - value: {{ value | yaml_encode }}
    - user: {{ gitlab.user }}
    - global: true
{% endfor %}
