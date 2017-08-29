---
letsencrypt_domain: ehr.librehealth.io
letsencrypt_pause_services:
  - apache2

users:
 tony:
   comment: Tony McCormick
   groups: 'admin'
   ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA47WX9XHmOpm4Bp/3wTDIgMHugrxT9DtqAjES36nfL7BNThP1kVtRkACgF76ewGzCK7onlaG0NvukSC27I53MYiR0jC3NYX2g6NzqRVi4UH0oFwbuwt3Tz9QlCzQijyprgam8/lSgpKBrf7UXBEQmU99A7Zb395NrW1I98S/c32KDCvXC1rlNyQUmTmyvLQ9Z64tMEtGg5Mkj0w/qxf4dmDbeu14yLwiXbXuNnX6IxGIKewxG+bFqtwmbNIlXdxMNw99NHA1A4BDCVJsROcvejKBB/zHkQwSLejsE6q0l1LdNL64XH16NRw4Yg99XiQlV0eO1NvEV1wfUdLEnlimleQ== tony@mi-squared.com"

 aethelwulffe:
   comment: Art Eaton
   groups: 'admin'
   ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAo1+hEV63gF2dEjRiOzfWzzMlPOukW5imQq2NS+Z0TrZ9i73vNqkPF8O081LvBfcaYAnXfdfBACxGpGOJ05wM+M+W5nuG/Wx9isZv7T8kYhWBBxuKf0Cr3f1EDcSd//MOekiJKIG4UHsZo9krAJD6pcstDH+IALL4EWL2WC8TJSAEZ6vJ5CuuwKPGG/bD5ix5KuDWhhQHMwuNcFgfIh9bz/JZeqcvalxx4oNOn6fms13mi0IQOOZUGSNjmE7lKN/KkrjtMORkYINq8w1sEfcc4HovdW06nj/djkj1XXksiyvVFix4te6Nj8pKWIWV1ci3WKuuhvFeqr0F6wmpiwYyUw== art@starfrontiers.org"
 yehster:
   comment: Kevin Yeh
   groups: 'admin'
   ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgHZTqZAFnreLSsn385npe8WM+ZdpH3qGbQMIDU1+5lbslZbsSjcPtYHiHzPdnV5xaDW15Xeh0LCW5r10jBuxGMoS1S2+w0nTeYDIjyKK5KXVX6sPvtyn3DpnSXBjwxo7VUvHVIAQKV0MyhCfno6r3C3+CdZSxtgre46qv2Ng0F9RFJpA4xMYnBTkVSm9KcsQHjiXgo5GUfn7v7HWAMJYISDLKunH24ZBJ+7NmP6XYUw0S6/VojnOgnJnIjJRwELao/COiqwbq6m3ASD5slHDw6q4a/eA/egxnOXd2bdas8J+KmjaW0tHS6i772JJn6/JtuJXzIbTEUw5WOgF32+Wgw== rsa-key-20170420"

apache_listen_ip: "69.195.153.59"
apache_vhosts_ssl:
  - servername: "ehr.librehealth.io"
    serveradmin: infrastructure@librehealth.io
    documentroot: "/opt/ehr"
    certificate_file: "/etc/letsencrypt/live/ehr.librehealth.io/fullchain.pem"
    certificate_key_file: "/etc/letsencrypt/live/ehr.librehealth.io/privkey.pem"
    extra_parameters: |
      <Location /server-status>
         SetHandler server-status
         Allow from 127.0.0.1
         Deny from all
      </Location>
      <Directory "/opt/ehr">
            Options Indexes FollowSymLinks
            AllowOverride all
            Require all granted
        </Directory>
        <Directory "/opt/ehr/downloads">
          Options +Indexes
        </Directory>
        <Directory "/opt/ehr/sites">
            AllowOverride None
        </Directory>
        <Directory "/opt/ehr/sites/*/documents">
            order deny,allow
            Deny from all
        </Directory>
        <Directory "/opt/ehr/sites/*/edi">
            order deny,allow
            Deny from all
        </Directory>
        <Directory "/opt/ehr/sites/*/era">
            order deny,allow
            Deny from all
        </Directory>
        RewriteEngine On

        # NHANES
        RewriteRule ^/nhanes/?$     https://ehr.librehealth.io/?site=nhanes [L,R]
        RewriteRule ^/nhanes/(.*)$  https://ehr.librehealth.io/$1?site=nhanes [L,R]

        # Harrisburg University
        RewriteRule ^/hu/?$     https://ehr.librehealth.io/?site=hu [L,R]
        RewriteRule ^/hu/(.*)$  https://ehr.librehealth.io/$1?site=hu [L,R]

        # Lake–Sumter State College
        RewriteRule ^/lssc/?$     https://ehr.librehealth.io/?site=lssc [L,R]
        RewriteRule ^/lssc/(.*)$  https://ehr.librehealth.io/$1?site=lssc [L,R]

        # Northern Kentucky University
        RewriteRule ^/nku/?$     https://ehr.librehealth.io/?site=nku [L,R]
        RewriteRule ^/nku/(.*)$  https://ehr.librehealth.io/$1?site=nku [L,R]

        # University of Maryland
        RewriteRule ^/umd/?$     https://ehr.librehealth.io/?site=umd [L,R]
        RewriteRule ^/umd/(.*)$  https://ehr.librehealth.io/$1?site=umd [L,R]

apache_vhosts:
  - servername: "ehr.librehealth.io"
    serveradmin: infrastructure@librehealth.io
    documentroot: "/opt/ehr"
    extra_parameters: |
      Redirect permanent / https://ehr.librehealth.io
  - servername: "nhanes.librehealth.io"
    serveradmin: infrastructure@librehealth.io
    documentroot: "/opt/ehr"
    extra_parameters: |
      Redirect permanent / https://ehr.librehealth.io/nhanes

apache_mods_enabled:
  - rewrite.load
  - php7.0.load
  - status.load

datadog_checks:
  apache:
    init_config:
    instances:
      - apache_status_url: http://localhost/server-status?auto
        tags:
          - instance:ehr

datadog_config:
  tags: "provider:proxmox,location:MCI,service:ehr,ansible:partial,provisioner:manual"
