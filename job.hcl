variable "mariadb_root_pw" {
  type = string
  description = "Root PW MariaDB"
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

job "backupper" {
  datacenters = ["dc1"]
  type = "batch" 

  periodic {
    cron             = "0 5 * * * *"
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
      }

      
      config {
        image = "ghcr.io/janst123/nomad-backupper:latest"
        force_pull = true
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