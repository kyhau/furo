# #############################################################################
# Install and maintain GrayLog on a server (started from an AMI in
# https://github.com/Graylog2/graylog2-images/tree/2.0/aws)
# #############################################################################

{% set hostname = grains.host %}
{% set domain_name = salt['pillar.get']('domains:default') %}
{% set graylog_ip = salt['pillar.get']('graylog-server-ips:' + hostname, None) %}
{% set root_admin_name = salt['pillar.get']('graylog:root-admin-name') %}
{% set root_admin_pass = salt['pillar.get']('graylog:root-admin-pass') %}
{% set aws_plugin_version = salt['pillar.get']('graylog:aws-plugin-version') %}

graylog-user:
  user.present:
    - name: graylog
    - home: /var/opt/graylog
    - system: True

# Setup the first time with https enabled
graylog-reconfig:
  cmd.run:
    - name: >
        graylog-ctl reconfigure &&
        graylog-ctl enforce-ssl &&
        graylog-ctl set-external-ip https://{{ hostname }}.{{ domain_name }}:443/api &&
        graylog-ctl reconfigure
    - unless: ps waux | grep graylog-server | grep -v grep

# Install plugin and restart graylog-server if not exist
graylog-download-plugin-aws:
  cmd.run:
    - name: >
        wget -O /opt/graylog/plugin/graylog-plugin-aws-{{ aws_plugin_version }}.jar https://github.com/Graylog2/graylog-plugin-aws/releases/download/{{ aws_plugin_version }}/graylog-plugin-aws-{{ aws_plugin_version }}.jar &&
        graylog-ctl restart graylog-server
    - unless: ls /opt/graylog/plugin/graylog-plugin-aws-{{ aws_plugin_version }}.jar

# Set root/admin name and password
graylog-admin-pass:
  cmd.run:
    - name: >
        graylog-ctl set-admin-username {{ root_admin_name }} &&
        graylog-ctl set-admin-password {{ root_admin_pass }}
        graylog-ctl reconfigure

# Install custom SSL certificates
# For nginx, need to combine the site cert and intermediate crt
graylog-ssl-certs:
  cmd.run:
    - name: >
        cat /etc/certificates/{{ domain_name }}/default.crt /etc/certificates/{{ domain_name }}/intermediate.crt > graylog.crt &&
        cp /etc/certificates/{{ domain_name }}/default.key /opt/graylog/conf/nginx/ca/graylog.key &&
        graylog-ctl restart nginx
