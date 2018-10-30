{% from 'gitlab/map.jinja' import gitlab with context %}

{% set service_function = 'running' if gitlab.service_enabled else 'dead' %}

{% if grains.os_family == 'FreeBSD' %}
gitlab_service_script:
  file.managed:
    - name: /usr/local/etc/rc.d/{{ gitlab.service }}
    - source: salt://gitlab/files/freebsd-rc.sh.j2
    - template: jinja
    - mode: 755
    - context:
      directory: {{ gitlab.directory }}
      user: {{ gitlab.user }}
      workhorse_directory: {{ gitlab.workhorse.directory }}
      gitaly_directory: {{ gitlab.gitaly.directory }}
{% endif %}

gitlab_service:
  service.{{ service_function }}:
    - name: {{ gitlab.service }}
    - enable: {{ gitlab.service_enabled }}
