*This project has been created as part of the 42 curriculum by \<thelee\>*

---

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small infrastructure composed of different services using **Docker** and **Docker Compose**, all running inside a virtual machine.

Each service runs in its own dedicated container, built from either Alpine or Debian base images. The stack includes a web server, a content management system, and a database — wired together through a custom Docker network, with persistent data managed via Docker volumes.

### Design Choices

#### Virtual Machines vs Docker

| | Virtual Machines | Docker |
|---|---|---|
| **Isolation** | Full OS-level isolation | Process-level isolation |
| **Weight** | Heavy (full OS per VM) | Lightweight (shared kernel) |
| **Startup time** | Minutes | Seconds |
| **Use case** | Complete environment separation | Service-level containerization |

Docker was chosen for this project because it is lightweight, fast, and fits perfectly for orchestrating multiple small services. VMs are used as the host environment (as required by the subject), while Docker handles service isolation within that VM.

#### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|---|---|---|
| **Storage** | Files (e.g., Docker secrets, `.env` excluded from Git) | `.env` file or shell environment |
| **Security** | More secure — not exposed in process environment | Visible to all processes, easier to leak |
| **Use case** | Passwords, API keys, tokens | Non-sensitive config (ports, hostnames) |

This project uses **Docker secrets** and/or local `.env` files (excluded from Git via `.gitignore`) to store sensitive credentials. Hardcoding credentials in source files or committing them to the repository is strictly forbidden.

#### Docker Network vs Host Network

| | Docker Network | Host Network |
|---|---|---|
| **Isolation** | Containers communicate on a private internal network | Containers share the host's network stack |
| **Security** | Better — services are not directly exposed | Lower — all ports are open on the host |
| **Use case** | Multi-service architectures | Performance-critical single-container setups |

This project uses a **custom Docker bridge network** so that containers can communicate with each other by service name, while remaining isolated from the host network.

#### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker | Host filesystem |
| **Portability** | High — works across environments | Low — depends on host path |
| **Use case** | Persistent data (DB, uploads) | Development (live code reload) |

**Docker volumes** are used in this project to ensure persistent data storage (database files, WordPress uploads) that survives container restarts and is managed cleanly by Docker.

### Sources / Images Included

| Service | Base Image | Role |
|---|---|---|
| NGINX | Alpine | Reverse proxy / TLS termination |
| WordPress | Alpine + PHP-FPM | CMS application |
| MariaDB | Alpine | Relational database |

---

## Instructions

### Prerequisites

- A Unix-based system (Linux or macOS) or a virtual machine
- Docker and Docker Compose installed
- `make` available on the system

### Setup

1. Clone the repository


2. Create your secrets and configuration files as described in `DEV_DOC.md`.

3. Build and start the stack:
   ```bash
   make
   ```

4. To stop the stack:
   ```bash
   make down
   ```

5. To clean up all containers, volumes, and built images:
   ```bash
   make fclean
   ```

Refer to `DEV_DOC.md` for full developer setup instructions and `USER_DOC.md` for end-user guidance.

---

## Resources

### Documentation & References

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI documentation](https://developer.wordpress.org/cli/commands/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [TLS/SSL overview — Mozilla](https://developer.mozilla.org/en-US/docs/Web/Security/Transport_Layer_Security)

### Articles & Tutorials

- [Understanding Docker networking](https://docs.docker.com/network/)
- [Docker volumes vs bind mounts](https://docs.docker.com/storage/)
- [Best practices for Docker secrets management](https://docs.docker.com/engine/swarm/secrets/#about-secrets)
- [PHP-FPM configuration guide](https://www.php.net/manual/en/install.fpm.configuration.php)

### AI Usage

AI was used during this project for the following tasks:

- **Dockerfile writing assistance**: Getting correct syntax for multi-stage builds and Alpine package installation.
- **NGINX configuration**: Help with TLS configuration directives and FastCGI proxy settings for PHP-FPM.
- **Debugging**: Analyzing error logs and identifying misconfigurations in Docker Compose service dependencies.
- **Documentation**: Drafting and structuring this README.md, `USER_DOC.md`, and `DEV_DOC.md`.