##############################################################################
# Install nodejs
# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
##############################################################################

# Install latest Node.js v7.x
nodejs-install-version:
  cmd.run:
    - name: >
        curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash - &&
        sudo apt-get install -y nodejs
