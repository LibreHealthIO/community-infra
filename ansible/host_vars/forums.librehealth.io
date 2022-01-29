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
