---
letsencrypt_domain: radiology.librehealth.io
letsencrypt_email: infrastructure@librehealth.io
letsencrypt_force_renew: false
letsencrypt_pause_services:
  - nginx

nginx_ppa_use: true
nginx_ppa_version: stable
nginx_remove_default_vhost: true
nginx_vhosts_filename: "vhosts.conf"
nginx_vhosts:
- listen: "80 default_server"
  server_name: "radiology.librehealth.io"
  extra_parameters: |
    return 301 https://$host$request_uri;
- listen: "443 ssl"
  server_name: "radiology.librehealth.io"
  extra_parameters: |
    access_log /var/log/nginx/radiology_access.log;
    error_log /var/log/nginx/radiology_error.log;
    ssl_certificate /etc/letsencrypt/live/radiology.librehealth.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/radiology.librehealth.io/privkey.pem;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security max-age=15768000;
    root /usr/share/nginx/html;
    location / {
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forward-Proto http;
      proxy_pass http://127.0.0.1:8080/;
    }
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }

java_packages:
  - openjdk-8-jre-headless

tomcat_version: 8
tomcat_port: 8080
tomcat_control_port: 8005
tomcat_catalina_home: "/usr/share/tomcat{{tomcat_version}}"
tomcat_catalina_base: "/var/lib/tomcat{{tomcat_version}}"
tomcat_java_opts: -Djava.awt.headless=true -Xmx4096m  -Xms1024m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC
tomcat_catalina_opts:
option_tomcat_admin_install: false
option_tomcat_user_install: false
option_tomcat_native_install: true
option_tomcat_mysql_jbdc_install: true
datadog_checks:
  nginx:
    init_config:
    instances:
      - nginx_status_url: https://localhost/nginx_status/
        ssl_validation: False
        tags:
          - instance:radiology
