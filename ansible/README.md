Librehealth Community Infrastructure Ansible Playbook
======================

# A note about this repo
There are files which are encrypted using [git-crypt][], in order to work with this, you must have a published PGP key.

Ansible will not work with the files in an encrypted state.

# Get started and stuff

`ansible-galaxy install -p roles -r requirements.yml`

This assumes you are in the `ansible` directory where this README resides

## Unlocking [git-crypt][] encrypted files

### Install [git-crypt][]

Assuming you have given us your key, then you can simply do [follow these instructions](https://raw.githubusercontent.com/AGWA/git-crypt/master/INSTALL.md)

### Unlocking (it's a one-time thing)
```sh
$ git-crypt unlock
```

Enter your key passphrase and it should unlock for you -- beyond that -- everything is done transparently, no work is necessary on your part.

### Locking (you will need to unlock before ansible even runs!)

To relock it
```sh
$ git-crypt lock
```
### Check Status of what's encrypted:

```sh
$ git-crypt status
```
**PLEASE AVOID RUNNING `git-crypt init`!!**

For a list of files which are encrypted you can check out `.gitattributes` in the root of this repository.

## Our Plays


### Common Play (`lh-common.yml`)
This play runs the following roles which are common with all servers, regardless of the Tech Stack used. All plays include this.

This includes:

- Setting up users
- installing sudo
- installing sshd
- configuring ufw
- configuring ntp for clock synchronization
- setting the timezone (UTC)

### Datadog Play (`datadog.yml`) (included in the Common Play)
Installs the [datadog agent](https://datadog.com) and setting up checks. This is run first and is included in the Common Play.

This play is encrypted.

### [PostgreSQL][] Play (`lh-postgres.yml`) (included in the Common Play)
Installs and configures [PostgreSQL][] for hosts that need it. This is only run if needed on the given host. It is included in the Common Play.

### [Certbot][] Play (`certbot.yml`)
Provisions and renews [Let's Encrypt SSL Certificates](https://letsencrypt.org) using [Certbot][]

Installs Certbot if it is not installed on the server. This is written to be run on its own as-needed (every 3 months).

### [nginx][] Play (`lh-nginx.yml`)
Installs and configures nginx

### [LibreHealth EHR][] / [PHP][] Play (`lh-php.yml`)
Installs Apache, [PHP](https://php.net), [Composer](https://getcomposer.org), and [Imagemagick](https://www.imagemagick.org/script/index.php).

### [Docker][] play (`lh-docker.yml`)
installs [docker](https://docs.docker.com/engine/)/[docker-compose](https://docs.docker.com/compose/)

### [LibreHealth Toolkit][] / [LibreHealth Radiology][] (`lh-tomcat.yml`)
This sets up and installs java, and tomcat.


### Site-wide play which includes everything (`site.yml`)
Includes all of the above(except `cerbot.yml` and `update.yml`). This is the we run.

## Requirements
* This repo.
* [ansible  2.1+ installed](http://docs.ansible.com/ansible/intro_installation.html) on the same machine the repo is cloned to.


## How to use this
How this is run is dependent on what project you are working with.
### To run for all hosts

`ansible-playbook -i inventories/all site.yml`

### For [LibreHealth EHR][]

`ansible-playbook -i inventories/all -l ehr site.yml`

### For [LibreHealth Toolkit][] / [LibreHealth Radiology][]

#### [LibreHealth Radiology][]

`ansible-playbook -i inventories/all -l radiology site.yml`

#### [LibreHealth Toolkit][]

`ansible-playbook -i inventories/all -l toolkit site.yml`

#### For Both [LibreHealth Toolkit][] and [LibreHealth Radiology][]

`ansible-playbook -i inventories/all -l tomcat site.yml`

## Running example ad-hoc commands

#### Update all packages playbook
This will do a dry run of updating all packages on all servers

`ansible-playbook -i inventories/all update.yml --check -v`

When satisfied this will not breaking anything drop the `--check` and it will update all servers in the inventories.

#### Update a certain package to latest version

`ansible -i inventories/all all -m apt -a "update_cache=yes name=openssl state=latest" --become`

This will only update the package to the latest version if it is already installed.  It will not install the openssl package on hosts that do not have it installed.

[Certbot]: https://certbot.eff.org
[git-crypt]: https://github.com/AGWA/git-crypt
[LibreHealth EHR]: https://librehealth.io/projects/lh-ehr
[LibreHealth Radiology]: https://librehealth.io/projects/lh-radiology
[LibreHealth Toolkit]: https://librehealth.io/projects/lh-toolkit
[PostgreSQL]: https://www.postgresql.org
[Docker]: https://docs.docker.com
[PHP]: https://php.net
[nginx]: https://nginx.com
