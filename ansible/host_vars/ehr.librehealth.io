---

users:
 tony:
   comment: Tony McCormick
   groups: 'admin'
   ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA47WX9XHmOpm4Bp/3wTDIgMHugrxT9DtqAjES36nfL7BNThP1kVtRkACgF76ewGzCK7onlaG0NvukSC27I53MYiR0jC3NYX2g6NzqRVi4UH0oFwbuwt3Tz9QlCzQijyprgam8/lSgpKBrf7UXBEQmU99A7Zb395NrW1I98S/c32KDCvXC1rlNyQUmTmyvLQ9Z64tMEtGg5Mkj0w/qxf4dmDbeu14yLwiXbXuNnX6IxGIKewxG+bFqtwmbNIlXdxMNw99NHA1A4BDCVJsROcvejKBB/zHkQwSLejsE6q0l1LdNL64XH16NRw4Yg99XiQlV0eO1NvEV1wfUdLEnlimleQ== tony@mi-squared.com"

 aethelwulffe:
   comment: Art Eaton
   groups: 'admin'
   ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAo1+hEV63gF2dEjRiOzfWzzMlPOukW5imQq2N S+Z0TrZ9i73vNqkPF8O081LvBfcaYAnXfdfBACxGpGOJ05wM+M+W5nuG/Wx9isZv 7T8kYhWBBxuKf0Cr3f1EDcSd//MOekiJKIG4UHsZo9krAJD6pcstDH+IALL4EWL2 WC8TJSAEZ6vJ5CuuwKPGG/bD5ix5KuDWhhQHMwuNcFgfIh9bz/JZeqcvalxx4oNO n6fms13mi0IQOOZUGSNjmE7lKN/KkrjtMORkYINq8w1sEfcc4HovdW06nj/djkj1 XXksiyvVFix4te6Nj8pKWIWV1ci3WKuuhvFeqr0F6wmpiwYyUw== art@starfrontiers.org"


apache_listen_ip: "69.195.153.59"
apache_listen_port: 80
apache_listen_port_ssl: 443
apache_create_vhosts: true
apache_vhosts_filename: "vhosts.conf"
apache_remove_default_vhost: true
apache_global_vhost_settings: |
  DirectoryIndex index.php index.html
apache_vhosts:
  # Additional properties: 'serveradmin, serveralias, extra_parameters'.
  - servername: "ehr.librehealth.io"
    serveradmin: infrastructure@librehealth.io
    documentroot: "/opt/ehr"
    extra_parameters: |
      Redirect permanent / https://ehr.librehealth.io
      <Location /server-status>
         SetHandler server-status
         Allow from 127.0.0.1
         Deny from all
      </Location>
      <Directory "/opt/ehr">
            AllowOverride FileInfo
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

apache_mods_enabled:
  - rewrite.load
  - php7.0.load
  - status.load
php_enable_webserver: false
php_max_input_vars: "3000"
php_short_open_tag: true
php_max_input_time: "90"

php_packages:
  - php7.0-common
  - php7.0-cli
  - php7.0-dev
  - php7.0-fpm
  - libpcre3-dev
  - php7.0-gd
  - php7.0-curl
  - php7.0-imap
  - php7.0-json
  - php7.0-opcache
  - php7.0-xml
  - php7.0-mbstring
  - php7.0-mcrypt
  - php7.0-soap

letsencrypt_domain: ehr.librehealth.io
letsencrypt_email: infrastructure@librehealth.io
letsencrypt_force_renew: false
letsencrypt_pause_services:
  - apache2
datadog_checks:
  apache:
    init_config:
    instances:
      - apache_status_url: http://localhost/server-status?auto
        tags:
          - instance:ehr
