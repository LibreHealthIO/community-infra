# vim: set ft=yaml:
# -*- mode: yaml -*-
# vscode: language yaml
---
letsencrypt_domain: toolkit.librehealth.io

datadog_checks:
  nginx:
    init_config: {}
    instances:
      - nginx_status_url: https://localhost/nginx_status/
        ssl_validation: false
        tags:
          - instance:toolkit

datadog_config:
  tags: "provider:osuosl,location:or,service:toolkit,ansible:full,provisioner:terraform"

nginx_extra_http_options: |

  limit_req_zone $binary_remote_addr zone=toolkit_limit:10m rate=10r/s;
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
    server_name: "toolkit.librehealth.io"
    filename: "toolkit.librehealth.io.80.conf"
    extra_parameters: |
      location ^~ /.well-known/acme-challenge/ {
        root /usr/share/nginx/html;
        try_files $uri =404;
      }

      location / {
        return 301 https://$host$request_uri;
      }

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
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
      ssl_prefer_server_ciphers on;
      ssl_session_timeout 1d;
      ssl_session_cache shared:SSL:50m;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

      location / {
        if ($block_agent = 1) {
          return 403;
        }

        # Apply rate limiting
        limit_req zone=toolkit_limit burst=20 nodelay;

        # Global CORS Headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, PATCH, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization' always;

        # Preflight handling
        if ($request_method = 'OPTIONS') {
          add_header 'Access-Control-Max-Age' 1728000;
          add_header 'Content-Type' 'text/plain charset=UTF-8';
          add_header 'Content-Length' 0;
          return 204;
        }

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://127.0.0.1:8080/;
      }

      location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        allow ::1;
        deny all;
      }
