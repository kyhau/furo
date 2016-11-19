mysql-server:
  pkg:
    - installed

mysql-client:
  pkg:
    - installed

mysql:
  service:
    - running
    - enable: True
