---
users:
 ivange94:
   comment: Ivange Larry
   groups: 'admin'
   ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2TCT52I9Ctiw3okZ9xeC1os8uSHhXtbsjh5C2FXkkWkH9muqstRZI8Z0jr6Fw+Xd9muR6eof4SCiOZFoeZU6pVtrEtbvOid9UzZnUhh3hRkqRigdq2S9NTla037iiLn/z1udhghYn5jEmmM7vFndiGR2u78nr3T3xoz2bHodgF7RvbF1Wk+n6nhJoLKOq6DxmKQDEALOJjCDZR3PxZYT5p3xifftPAqb8E0smE0nTnM07BlBg84duhyOgty6zyQaIZjXteO3m0aJFCWgDUQR8ybDCBF2gcpI6gEp0Cy9WMmC8ggWcbSx6LVVqRjCWBB2mKY79fyw3fEwyLXsAq2A9 ivange@Ivanges-MacBook-Pro-3.local"
   gichoya:
     comment: Judy Gichoya
     groups: 'admin'
     ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDXi332kbAiyAdzIOdy8HEOF9gmN290X7HAlSq5/jzBQrauHDnNT7Z1Ktkhj+k8K3jsvQuZcHkIvVG8BXvDVkep8yzQvRPuMweWvYD58ImejRo0f9roz8TfhHxNWl2IY+QtNmR8DZ8EU2MRqNgdNcMqoDY7KVqfWaB2NRTiinigEMDLOCr4793tJX2yHN7DnqfzJh6gk0xsLD3/BXMbVwH44Y/WrgX4PTPdVmpxDYU2bywZd1ziVk9/fY4Pql0k4Eu6drQ5XxH7oSkDLRgBGbzCBKp/hc6IuW8F+36u1mU6Y7Wk4yYNAgHAsbMWbjBEGVqyYjVkXMUSsHhHL/kWnLJ judywawira@gmail.com"

letsencrypt_domain: radiology.librehealth.io
letsencrypt_email: infrastructure@librehealth.io
letsencrypt_force_renew: false
letsencrypt_pause_services:
  - nginx

nginx_vhosts:
- listen: "80 default_server"
  server_name: "radiology.librehealth.io"
  return: "301 https://$host$request_uri"
  filename: "radiology.librehealth.io.80.conf"

- listen: "443 ssl http2 default_server"
  server_name: "radiology.librehealth.io"
  access_log: "/var/log/nginx/radiology_access.log"
  error_log: "/var/log/nginx/radiology_error.log"
  root: "/usr/share/nginx/html"
  index: "index.html index.htm"
  extra_parameters: |
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

datadog_checks:
  nginx:
    init_config:
    instances:
      - nginx_status_url: https://localhost/nginx_status/
        ssl_validation: False
        tags:
          - instance:radiology
datadog_config:
  tags: "provider:rackspace,location:iad,service:radiology,ansible:partial,provisioner:manual"
