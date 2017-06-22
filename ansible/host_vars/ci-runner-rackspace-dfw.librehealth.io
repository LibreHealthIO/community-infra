---
gitlab_multirunner:
  runners:
    - name: ci-docker-runner
      state: present
      ci_server: https://gitlab.com/ci
      token: # ask for this.
      executor: docker
      docker_image: ubuntu:16.04
datadog_config:
  tags: "provider:rackspace,location:dfw,service:gitlab_ci_runner,ansible:full,provisioner:manual"
