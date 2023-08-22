# Nomad backupper

This can be installed as a periodic nomad job and will backup your MariaDB Databases and optionally your GitHub repositories to an FTP Server. It's mainly for my personal use case but can of course be adapted to yours.
It corresponds perfectly with my [gridscale nomad single-cluser setup](https://github.com/JanST123/nomad-gridscale).

## Features
🚀 perdiodically dumps all your **MariaDB databases** and backups them to an FTP

🚀 optionally also dumps all your **GitHub repos** and backups them to the FTP within the same run (using [ghbackup](https://github.com/qvl/ghbackup))

🚀 optionally sends you a **status mail** after the backup is done, telling you if everything was okay or something went wrong

🚀 rotates the backups on a 2-day basis (so you backups from 2 days)

🚀 configurable with nomad variables


## MariaDB Backup

The MariaDB backup is not optional. It uses nomad *service discovery* and assumes the MariaDB database service in your nomad cluster is named `mariadb-server`. If you want to customize that edit the `job.hcl` file.
It will dump all databases (using `mariadb-dump --all-databases`)

## GitHub backup
If you set the `github_token` variable the container will also run [ghbackup](https://github.com/qvl/ghbackup)) on your GitHub Account, cloning and packing all your repos and also adds them to the FTP backup. If you also provide `github_account` variable it will only backup the repos from this account (otherwise it will backup **all repos** you have access to).

The token can be generated in the [Developer Settings](https://github.com/settings/tokens) in your github account.

## Monitoring status mail
Set the `monitoring_email` email variable and the `smtp_*` variables and you will receive a status mail after each backup run. It will tell if the backup run was fine or not.

It will warn if
* The size of the new backup differs more than 5% to the last backup (remember we backup 2 days)
* No two backup files were found on the FTP (fine for the first run of course)
* The backup is too old (e.g. no new backup was uploaded)

## Install on nomad

Run the following command with the environment variables
```sh
nomad job run 
  -var mariadb_root_pw=<MARIADB ROOT PASSWORD> 
  -var ftp_host="<HOST OF YOUR BACKUP FTP>" 
  -var ftp_user="<USER FOR THE BACKUP FTP>" 
  -var ftp_pass="<PASSWORD FOR THE BACKUP FTP>"
  -var ftp_dir="<PATH ON THE FTP SERVER>"
  -var github_token=<OPTIONAL YOUR GITHUB TOKEN IF GITHUB SHOULD BE BACKED UP TOO>
  -var github_account=<OPTIONAL YOUR GITHUB ACCOUNT NAME IF ONLY THIS REPOS SHOULD BE BACKED UP>
  -var monitoring_email=<OPTIONAL YOUR EMAIL ADDRESS TO RECEIVE BACKUP STATUS MAILS>
  -var smtp_host=<HOSTNAME OF SMTP SERVER YOU OWN OR RENTED TO SEND BACKUP STATUS MAIL FROM>
  -var smtp_user=<USER OF SMTP SERVER YOU OWN OR RENTED TO SEND BACKUP STATUS MAIL FROM>
  -var smtp_pass=<PASSWORD OF SMTP SERVER YOU OWN OR RENTED TO SEND BACKUP STATUS MAIL FROM>
  job.hcl
```

**If you want to edit when the periodic job is run** edit the `perdiodic.cron` in the `job.hcl` file.