---
letsencrypt_domain: toolkit.librehealth.io
letsencrypt_email: infrastructure@librehealth.io
letsencrypt_force_renew: false
letsencrypt_pause_services:
  - nginx

nginx_vhosts:
- listen: "80 default_server"
  server_name: "toolkit.librehealth.io"
  return: "301 https://$host$request_uri"
  filename: "toolkit.librehealth.io.80.conf"

- listen: "443 ssl http2 default_server"
  server_name: "toolkit.librehealth.io"
  access_log: "/var/log/nginx/toolkit_access.log"
  error_log: "/var/log/nginx/toolkit_error.log"
  root: "/usr/share/nginx/html"
  index: "index.html index.htm"
  extra_parameters: |
    ssl_certificate /etc/letsencrypt/live/toolkit.librehealth.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/toolkit.librehealth.io/privkey.pem;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security max-age=15768000;

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

    location ^~ /.well-known/acme-challenge/ {
      root /usr/share/nginx/html;
    }

datadog_checks:
  nginx:
    init_config:
    instances:
      - nginx_status_url: https://localhost/nginx_status/
        ssl_validation: False
        tags:
          - instance:toolkit

datadog_config:
  tags: "provider:rackspace,location:iad,service:toolkit,ansible:partial,provisioner:manual"
