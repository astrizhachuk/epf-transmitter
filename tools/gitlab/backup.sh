#!/bin/bash

gitlab-ctl stop unicorn
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

gitlab-ctl status

gitlab-backup create BACKUP="`date +"%Y-%m-%d-%H-%M-%S"`" strategy=copy force=yes

cp /var/opt/gitlab/backups/*.tar /backups
tar cf /backups/"`date +"%Y-%m-%d-%H-%M-%S"`"_settings.tar /etc/gitlab/

gitlab-ctl restart
