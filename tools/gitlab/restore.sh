#!/bin/bash

cp /tmp/gitlab/dump_gitlab_backup.tar /var/opt/gitlab/backups/
chown git.git /var/opt/gitlab/backups/dump_gitlab_backup.tar

gitlab-ctl stop unicorn
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

gitlab-ctl status

gitlab-backup restore BACKUP=dump force=yes

cp -r /tmp/gitlab/settings/. /etc/gitlab

gitlab-ctl reconfigure
gitlab-ctl restart
