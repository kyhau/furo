##############################################################################
# awscli
##############################################################################
{% set profile_name = 'devops' %}
{% set aws_profile = salt['pillar.get']('aws:' + profile_name) %}
{% set access_key_id = aws_profile['access_key_id'] %}
{% set secret_access_key = aws_profile['secret_access_key'] %}

include:
  - python

##############################################################################
# Install awscli
awscli-install:
  cmd.run:
    - name: pip install -U awscli

###############################################################################
# Set up aws credentials and configs
/var/devops/.aws/credentials:
  file.managed:
    - source: salt://aws/.aws/credentials
    - makedirs: True
    - user: devops
    - group: devops
    - template: jinja
    - defaults:
        profile_name: default
        access_key_id: {{ access_key_id }}
        secret_access_key: {{ secret_access_key }}

/var/devops/.aws/config:
  file.managed:
    - source: salt://aws/.aws/config
    - makedirs: True
    - user: devops
    - group: devops
    - template: jinja
    - defaults:
        profile_name: default
        aws_region: ap-southeast-2
