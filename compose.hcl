locals {
    project_name = "ganapatih"
}

resource "docker_network" "backend" {
    name = "${local.project_name}_backend"
}

resource "docker_network" "frontend" {
    name = "${local.project_name}_frontend"
}

resource "docker_volume" "mysql_data" {
    name = "${local.project_name}_mysql_data"
}

resource "docker_volume" "grafana_data" {
    name = "${local.project_name}_grafana_data"
}

resource "docker_volume" "loki_data" {
    name = "${local.project_name}_loki_data"
}

resource "docker_container" "mysql" {
    name  = "${local.project_name}_mysql"
    image = "mysql:latest"
    ports {
        internal = 3306
        external = 3306
    }
    env = [
        "MYSQL_ROOT_PASSWORD=password",
        "MYSQL_HOST=mysql"
    ]
    # volumes {
    #     host_path      = "./restaurant/restaurantDB.txt"
    #     container_path = "/docker-entrypoint-initdb.d/initdb.sql"
    # }
    volumes {
        volume_name    = docker_volume.mysql_data.name
        container_path = "/var/lib/mysql"
    }
    networks = [docker_network.backend.name]
}

resource "docker_container" "restaurant" {
    name  = "${local.project_name}_restaurant"
    image = "restaurant:latest"
    ports {
        internal = 80
        external = 80
    }
    depends_on = [docker_container.mysql]
    volumes {
        host_path      = "./httpd.conf"
        container_path = "/etc/apache2/httpd.conf"
    }
    networks = [docker_network.backend.name, docker_network.frontend.name]
}

resource "docker_container" "grafana" {
    name  = "${local.project_name}_grafana"
    image = "grafana/grafana:latest"
    ports {
        internal = 3000
        external = 3000
    }
    env = [
        "GF_PATHS_PROVISIONING=/etc/grafana/provisioning",
        "GF_AUTH_ANONYMOUS_ENABLED=true",
        "GF_AUTH_ANONYMOUS_ORG_ROLE=Admin"
    ]
    volumes {
        volume_name    = docker_volume.grafana_data.name
        container_path = "/var/lib/grafana"
    }
    networks = [docker_network.backend.name, docker_network.frontend.name]
    depends_on = [docker_container.loki]
    entrypoint = [
        "sh",
        "-euc",
        <<-EOF
            mkdir -p /etc/grafana/provisioning/datasources
            cat <<EOT > /etc/grafana/provisioning/datasources/ds.yaml
            apiVersion: 1
            datasources:
                - name: Loki
                    type: loki
                    access: proxy
                    url: http://loki:3100
                    jsonData:
                        httpHeaderName1: "X-Scope-OrgID"
                    secureJsonData:
                        httpHeaderValue1: "tenant1"
            EOT
            /run.sh
        EOF
    ]
}

resource "docker_container" "loki" {
    name  = "${local.project_name}_loki"
    image = "grafana/loki:latest"
    ports {
        internal = 3100
        external = 3100
    }
    volumes {
        volume_name    = docker_volume.loki_data.name
        container_path = "/tmp/loki"
    }
    networks = [docker_network.backend.name]
}