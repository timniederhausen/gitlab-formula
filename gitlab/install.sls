{%- from 'gitlab/map.jinja' import gitlab, configs with context -%}

{%- for name in gitlab.prereq_pks %}
gitlab_prereq_{{ name }}:
  pkg.installed:
    - name: {{ name }}
{%- endfor %}

gitlab_redis_config:
  file.append:
    - name: {{ gitlab.redis.config_path }}
    - text:
      - port 0
      - unixsocket {{ gitlab.redis.socket_path }}
      - unixsocketperm 770

gitlab_user:
  user.present:
    - name: {{ gitlab.user }}
    - home: {{ gitlab.user_home }}
    - groups:
      - redis

gitlab_group:
  group.present:
    - name: {{ gitlab.group }}

{%- for name, value in gitlab.git_config.items() %}
gitlab_git_cfg_{{ name }}:
  git.config_set:
    - name: {{ name | yaml_encode }}
    - value: {{ value | yaml_encode }}
    - user: {{ gitlab.user }}
    - global: true
{%- endfor %}

gitlab_checkout:
  git.latest:
    - name: {{ gitlab.repository.url }}
    - target: {{ gitlab.directory }}
    - rev: {{ gitlab.repository.rev }}
    - user: {{ gitlab.user }}
    - force_reset: true
{%- if gitlab.repository.depth is defined %}
    - depth: {{ gitlab.repository.depth }}
{%- endif %}

gitlab_public_uploads:
  file.directory:
    - name: {{ gitlab.directory }}/public/uploads
    - user: {{ gitlab.user }}
    - group: {{ gitlab.group }}
    - mode: 700

{%- for name, value in configs.items() %}
{%  set has_example = name != 'database' -%}
{%- if has_example %}
gitlab_config_{{ name }}_source:
  file.copy:
    - name: {{ gitlab.directory }}/config/{{ name }}.yml
    - source: {{ gitlab.directory }}/config/{{ name }}.yml.example
{%-  endif %}

gitlab_config_{{ name }}:
  file.serialize:
    - name: {{ gitlab.directory }}/config/{{ name }}.yml
    - dataset: {{ gitlab[value] | yaml }}
    - formatter: yaml
    - user: {{ gitlab.user }}
    - group: {{ gitlab.group }}
    - mode: 600
{%-  if has_example %}
    - create: false
    - merge_if_exists: true
{%-  endif %}
{%- endfor %}

gitlab_bundle_install:
  cmd.run:
    - name: bundle install --deployment --without development test mysql aws kerberos && touch .bundle.stamp
    - runas: {{ gitlab.user }}
    - cwd: {{ gitlab.directory }}
    - creates: {{ gitlab.directory }}/.bundle.stamp

gitlab_shell:
  cmd.run:
    - name: >
        bundle exec rake gitlab:shell:install &&
        touch .shell.stamp
    - cwd: {{ gitlab.directory }}
    - runas: {{ gitlab.user }}
    - creates: {{ gitlab.directory }}/.shell.stamp
    - env:
      - RAILS_ENV: production
      - REDIS_URL: unix:{{ gitlab.redis.socket_path }}
      - SKIP_STORAGE_VALIDATION: 'true'

gitlab_workhorse:
  cmd.run:
    - name: >
        bundle exec rake "gitlab:workhorse:install[{{ gitlab.workhorse.directory }}]" &&
        touch .workhorse.stamp
    - cwd: {{ gitlab.directory }}
    - runas: {{ gitlab.user }}
    - creates: {{ gitlab.directory }}/.workhorse.stamp
    - env:
      - RAILS_ENV: production

gitlab_gitaly:
  cmd.run:
    - name: >
        bundle exec rake "gitlab:gitaly:install[{{ gitlab.gitaly.directory }},{{ gitlab.user_home }}/repositories,https://gitlab.com/timniederhausen/gitaly.git]" &&
        touch .gitaly.stamp
    - cwd: {{ gitlab.directory }}
    - runas: {{ gitlab.user }}
    - creates: {{ gitlab.directory }}/.gitaly.stamp
    - env:
      - RAILS_ENV: production

gitlab_setup:
  cmd.run:
    - name: >
        bundle exec rake gitlab:setup force=yes &&
        touch .setup.stamp
    - cwd: {{ gitlab.directory }}
    - runas: {{ gitlab.user }}
    - creates: {{ gitlab.directory }}/.setup.stamp
    - env:
      - RAILS_ENV: production
{%- if gitlab.root_user.password is defined %}
      - GITLAB_ROOT_PASSWORD: {{ gitlab.root_user.password | yaml_encode }}
{%- endif %}
{%- if gitlab.root_user.email is defined %}
      - GITLAB_ROOT_EMAIL: {{ gitlab.root_user.email | yaml_encode }}
{%- endif %}
