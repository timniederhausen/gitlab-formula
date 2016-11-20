{% from 'gitlab/map.jinja' import gitlab with context %}

gitlab_install:
  pkg.installed:
    - name: {{ gitlab.package }}
