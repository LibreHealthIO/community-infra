# vim: set ft=yaml:
# -*- mode: yaml -*-
# vscode: language yaml
---
letsencrypt_domain: chat.librehealth.io

datadog_checks:
  nginx:
    init_config: {}
    instances:
      - nginx_status_url: https://localhost/nginx_status/
        ssl_validation: false
        tags:
          - instance:rocketchat

datadog_config:
  tags: "provider:digitalocean,location:ams3,service:chat,ansible:partial,provisioner:terraform"


nginx_extra_http_options: |

  limit_req_zone $binary_remote_addr zone=rocketchat_limit:10m rate=20r/s;
  limit_req_status 429;

  map $http_user_agent $block_agent {
    default 0;

    # empty user agents
    "" 1;
    "-" 1;

    # Vulnerability/security scanners
    ~*visionheight 1;
    ~*CensysInspect 1;

    ~*Go-http-client 1;

    # Common aggressive crawlers & AI scrapers
    ~*(SemrushBot|AhrefsBot|MJ12bot|DotBot|PetalBot|BLEXBot|YandexBot|bingbot|GPTBot|ClaudeBot|CCBot) 1;
  }

nginx_vhosts:
  - listen: "80 default_server"
    server_name: "chat.librehealth.io"
    filename: "chat.librehealth.io.80.conf"
    extra_parameters: |
      location ^~ /.well-known/acme-challenge/ {
        root /usr/share/nginx/html;
        try_files $uri =404;
      }
      location / {
        return 301 https://$host$request_uri;
      }

  - listen: "443 ssl http2 default_server"
    server_name: "chat.librehealth.io"
    access_log: "/var/log/nginx/chat_access.log"
    error_log: "/var/log/nginx/chat_error.log"
    root: "/usr/share/nginx/html"
    index: "index.html index.htm"
    extra_parameters: |
      ssl_certificate /etc/letsencrypt/live/chat.librehealth.io/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/chat.librehealth.io/privkey.pem;
      ssl_dhparam /etc/ssl/certs/dhparam.pem;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
      ssl_prefer_server_ciphers on;
      ssl_session_timeout 1d;
      ssl_session_cache shared:SSL:50m;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

      location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        allow ::1;
        deny all;
      }

      location = /robots.txt {
        return 200 "User-agent: *\nDisallow: /\n";
        add_header Content-Type text/plain;
      }

      location / {
        if ($block_agent = 1) {
          return 403;
        }

        # Apply rate limiting
        limit_req zone=rocketchat_limit burst=30 nodelay;

        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Nginx-Proxy true;
        proxy_redirect off;
      }

      # location /hubot {
      #   if ($block_agent = 1) {
      #     return 403;
      #   }
      #
      #   # Apply rate limiting
      #   limit_req zone=chat_limit burst=30 nodelay;
      #
      #   proxy_pass http://localhost:3001/;
      #   proxy_http_version 1.1;
      #   proxy_set_header Upgrade $http_upgrade;
      #   proxy_set_header Connection "upgrade";
      #   proxy_set_header Host $http_host;
      #   proxy_set_header X-Real-IP $remote_addr;
      #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #   proxy_set_header X-Forwarded-Proto $scheme;
      #   proxy_set_header X-Nginx-Proxy true;
      #   proxy_redirect off;
      # }
