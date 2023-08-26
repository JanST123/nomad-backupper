variable "mariadb_root_pw" {
  type = string
  description = "Root PW MariaDB"
}


variable "ftp_host" {
  type = string
  description = "host of ftp to backup to"
}

variable "ftp_user" {
  type = string
  description = "user of ftp to backup to"
}

variable "ftp_pass" {
  type = string
  description = "pass of ftp to backup to"
}

variable "ftp_dir" {
  type = string
  description = "directory where the data should be uploaded to"
  default = "/"
}

variable "github_token" {
  type = string
  description = "GitHub token to take a backup"
  default = ""
}

variable "github_account" {
  type = string
  description = "GitHub account name to backup"
  default = ""
}

variable "monitoring_email" {
  type = string
  description ="set your email adress if you want to receive emails about backup monitoring"
}

variable "smtp_host" {
  type = string
  description ="set the host of your smtp server if you want to receive emails about backup monitoring"
}

variable "smtp_user" {
  type = string
  description ="set the auth user of your smtp server if you want to receive emails about backup monitoring"
}

variable "smtp_pass" {
  type = string
  description ="set password of your smtp server if you want to receive emails about backup monitoring"
}

job "backupper" {
  datacenters = ["dc1"]
  type = "batch" 

  periodic {
    cron             = "0 3 * * * *"
    prohibit_overlap = true
  }

  group "backupper" {
    count = 1

    task "backupper" {
      driver = "docker"

      env = {
        // MARIADB_DATABASE_HOSTNAME will be set by service detection
        // MARIADB_DATABASE_PORT will be set by service detection
        "MARIADB_ROOT_PASSWORD" = var.mariadb_root_pw
        "GITHUB_TOKEN" = var.github_token
        "GITHUB_ACCOUNT" = var.github_account
        "FTP_HOST" = var.ftp_host
        "FTP_USER" = var.ftp_user
        "FTP_PASS" = var.ftp_pass
        "FTP_DIR" = var.ftp_dir
        "MONITORING_EMAIL" = var.monitoring_email
        "SMTP_HOST" = var.smtp_host
        "SMTP_USER" = var.smtp_user
        "SMTP_PASS" = var.smtp_pass
      }

      
      config {
        image = "ghcr.io/janst123/nomad-backupper:0.0.12"
      }

      

      template {
        data = <<EOH
{{ range nomadService "mariadb-server" }}
MARIADB_DATABASE_HOSTNAME={{ .Address }}
MARIADB_DATABASE_PORT={{ .Port }}
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
    }


 }
}