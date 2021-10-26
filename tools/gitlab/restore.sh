#!/bin/bash

cp /backups/dump.tar /var/opt/gitlab/backups/dump_gitlab_backup.tar
chown git.git /var/opt/gitlab/backups/dump_gitlab_backup.tar

gitlab-ctl stop unicorn
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

gitlab-ctl status

gitlab-backup restore BACKUP=dump force=yes
tar xf /backups/settings.tar -C /

gitlab-ctl reconfigure
gitlab-ctl restart
