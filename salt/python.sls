python-os-pkgs:
  pkg.installed:
    - pkgs:
      - python
      - python-dev
      - python3
      - python3-dev
      - python-setuptools

python-pip:
  pkg.installed

python-environment:
  pip.installed:
    - requirements: salt://python/basic-requirements.txt
    - upgrade: True
    - require:
      - pkg: python-pip
