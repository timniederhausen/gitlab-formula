{% from 'gitlab/map.jinja' import gitlab %}

gitlab_setup:
  cmd.run:
    - name: |
        yes yes | rake gitlab:setup &&
        touch .setup.stamp
    - cwd: {{ gitlab.directory }}
    - creates: {{ gitlab.directory }}/.setup.stamp
    - env:
      - RAILS_ENV: production
      {%- if gitlab.root_password is defined %}
      - GITLAB_ROOT_PASSWORD: {{ gitlab.root_password | yaml_encode }}
      {%- endif %}
      {%- if gitlab.root_email is defined %}
      - GITLAB_ROOT_EMAIL: {{ gitlab.root_email | yaml_encode }}
      {%- endif %}

gitlab_assets_precompile:
  cmd.run:
    - name: rake assets:precompile
    - cwd: {{ gitlab.directory }}
    - env:
      - RAILS_ENV: production
    - onchanges:
      - pkg: gitlab_install
      - cmd: gitlab_setup
