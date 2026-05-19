---

ufw_rules:
  http:
    port: 80
    proto: tcp
    rule: allow
  https:
    port: 443
    proto: tcp
    rule: allow
  smtp:
    port: 25
    proto: tcp
    rule: allow

datadog_config:
  tags: "provider:digitalocean,location:ams3,service:discourse,ansible:partial,provisioner:terraform"

datadog_checks:
  ssl_check_expire_days:
    init_config:
    instances:
      - cert: /var/discourse/shared/standalone/letsencrypt/{{ inventory_hostname }}/fullchain.cer
