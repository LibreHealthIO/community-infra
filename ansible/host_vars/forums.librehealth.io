---

docker_storage_driver: aufs

ufw_rules:
  http:
    port: 80
    proto: tcp
    rule: allow
  https:
    port: 443
    proto: tcp
    rule: allow
