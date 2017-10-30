################################################################################
# Install New Relic Infrastructure Agent

{% set oscodename = grains.oscodename %}

# Create a configuration file, and add your license key
/etc/newrelic-infra.yml:
  file.managed:
    - user: root
    - group: root
    - contents_pillar: newrelic:license_key

/etc/apt/sources.list.d/newrelic-infra.list:
  file.managed:
    - user: root
    - group: root
    - contents: |
        deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt {{ oscodename }} main

# Install for Ubuntu 16 or Ubuntu 14
newrelic-infrastructure-apt-repo:
  cmd.run:
    - name: |
        curl https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
        sudo apt-get update
        sudo apt-get install newrelic-infra -y
