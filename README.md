# DevOps Tes


Menggunakan `docker compose` untuk menjalankan *services*
```yml
services:
  server:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - 9000:80
    environment:
      DB_HOST: db
      DB_NAME: restaurantdb
      DB_USER: root
      DB_PASS: password
    depends_on:
      - db
    develop:
      watch:
        - action: sync
          path: ./restaurant
          target: /var/www/html

  db:
    image: mysql:latest
    restart: always
    user: root
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: restaurantdb
    volumes:
      - mysql_data:/var/lib/mysql
    expose:
      - 3306
    healthcheck:
      test: ["CMD",
          "/usr/local/bin/healthcheck.sh",
          "--su-mysql",
          "--connect",
          "--innodb_initialized",]
      interval: 1m
      timeout: 30s
      retries: 5
      start_period: 30s
    networks:
      - backend

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_PATHS_PROVISIONING=/etc/grafana/provisioning
      - GF_AUTH_ANONYMOUS_ENABLED=true
      - GF_AUTH_ANONYMOUS_ORG_ROLE=Admin
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - frontend
      - backend
    depends_on:
      - loki
    entrypoint:
      - sh
      - -euc
      - |
        mkdir -p /etc/grafana/provisioning/datasources
        cat <<EOF > /etc/grafana/provisioning/datasources/ds.yaml
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
        EOF
        /run.sh

  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - loki_data:/tmp/loki
    networks:
      - backend

volumes:
  mysql_data:
  grafana_data:
  loki_data:

networks:
  backend:
  frontend:
```

Agar aplikasi dapat terhubung dengan *container database* MySQL, telah dilakukan perubahan pada 2 *file* `config.php` dan *file* `index.php`. Tidak lupa menambahkan file `.env` ke dalam folder aplikasi *restaurant*.
```php
    define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
    define('DB_USER', getenv('DB_USER') ?: 'root');
    define('DB_PASS', getenv('DB_PASS') ?: '');
    ...
```

> ---
> ### Github
>> Proyek dapat dilihat di alamat github saya: [github.com/masprast/akasa](github.com/masprast/akasa)
> ---

## Result
[ ] working app
[ ] system deployment
[ ] 

## Kendala
Selama seminggu ini saya terlalu fokus pada masalah saat akan deployment, yakni tidak dapat menginstall