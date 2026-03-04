*This project has been created as part of the 42 curriculum by \<thelee\>*

---

# Developer Documentation — Inception

This document is intended for **developers** who want to understand the project structure, set up the environment from scratch, and work with the Docker infrastructure.

---

## Prerequisites

Before getting started, ensure the following tools are installed on your system (or virtual machine):

| Tool | Minimum Version | Purpose |
|---|---|---|
| Docker | 20.x+ | Container runtime |
| Docker Compose | 2.x+ | Multi-container orchestration |
| make | any | Build automation |
| openssl | any | TLS certificate generation |

### Install Docker (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER
```

Log out and back in for group changes to take effect.

---

## Project Structure

```
inception/
├── Makefile
├── .env                    # Local environment variables
├── secrets/                # Docker secrets files (NOT on Git)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── wp_admin_password.txt
├── srcs/
│   ├── docker-compose.yml
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   └── conf/
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   └── conf/
│       └── mariadb/
│           ├── Dockerfile
│           └── conf/
└── README.md
```

---

## Environment Setup from Scratch

### 1. Clone the repository

### 2. Create secrets files

Launch `password.sh` after doing `chmod -x password.sh`

Make sure `secrets/` is listed in `.gitignore`.


## Building and Launching the Project

### Build and start all services

```bash
make
```

This runs `docker compose up --build -d` under the hood.

### Rebuild a single service

```bash
docker compose -f srcs/docker-compose.yml build <service-name>
docker compose -f srcs/docker-compose.yml up -d <service-name>
```

---

## Makefile Targets

| Target | Description |
|---|---|
| `make` | Build images and start all containers |
| `make down` | Stop and remove containers (volumes preserved) |
| `make clean` | Stop containers and remove images and volumes |
| `make fclean` | Full cleanup: containers, images, and volumes |
| `make re` | `fclean` + `make` (full rebuild) |

---

## Managing Containers

### List running containers

```bash
docker ps
```

### Access a container shell

```bash
docker exec -it <container-name> sh
```

### View logs

```bash
docker logs <container-name>
docker logs -f <container-name>   # follow mode
```

### Restart a single service

```bash
docker compose -f srcs/docker-compose.yml restart <service-name>
```

---

## Data Persistence

### Where data is stored

All persistent data is stored in **Docker volumes** managed by Docker:

| Volume | Service | Contents |
|---|---|---|
| `wordpress_data` | WordPress | WordPress core files and uploads |
| `mariadb_data` | MariaDB | Database files |

### Locate volumes on the host

```bash
docker volume ls
docker volume inspect inception_mariadb_data
```

The actual data lives under `/home/login/data/` on the host machine.

### Data lifecycle

- Data **persists** across `make down` / `make up` cycles.
- Data is **deleted** only when running `make fclean` (which runs `docker volume rm`).

> Always back up your volumes before running `fclean` if you need to preserve data.

---

## Network Architecture

All containers are connected to a single custom **bridge network** defined in `docker-compose.yml`:

```
[Browser] --HTTPS--> [NGINX :443] --> [WordPress :9000] --> [MariaDB :3306]
```

- NGINX is the only container with a port exposed to the host (`443`).
- WordPress and MariaDB are only reachable from within the Docker network.
- Containers reference each other by **service name** (e.g., `mariadb`, `wordpress`).