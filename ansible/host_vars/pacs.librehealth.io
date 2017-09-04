---
letsencrypt_domain: pacs.librehealth.io
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
  server_name: "pacs.librehealth.io"
  extra_parameters: |
    listen [::]:80 default_server;
    return 301 https://$host$request_uri;
  filename: "pacs.librehealth.io.80.conf"
- listen: "443 ssl http2 default_server"
  server_name: "pacs.librehealth.io"
  extra_parameters: |
    listen [::]:443 ssl http2 default_server;
    access_log /var/log/nginx/pacs_access.log;
    error_log /var/log/nginx/pacs_error.log;
    ssl_certificate /etc/letsencrypt/live/pacs.librehealth.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pacs.librehealth.io/privkey.pem;
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
    location  /orthanc/  {
      proxy_pass http://localhost:8042;
      proxy_set_header HOST $host;
      proxy_set_header X-Real-IP $remote_addr;
      rewrite /orthanc(.*) $1 break;
      add_header 'Access-Control-Allow-Credentials' 'true';
      add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
      add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
      add_header 'Access-Control-Allow-Origin' '*';
    }
    location /nginx_status {
          stub_status on;
          access_log off;
          allow 127.0.0.1;
          deny all;
      }
datadog_config:
  tags: "provider:rackspace,location:hkg,service:discourse,ansible:partial,provisioner:manual"
datadog_checks:
  nginx:
    init_config:
    instances:
      - nginx_status_url: https://localhost/nginx_status/
        ssl_validation: False
        tags:
          - instance:pacs
