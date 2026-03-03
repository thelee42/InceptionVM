*This project has been created as part of the 42 curriculum by \<thelee\>*

---

# User Documentation — Inception

This document is intended for **end users and administrators** who want to run, access, and manage the Inception stack without needing to understand the internal implementation details.

---

## Services Overview

The Inception stack provides the following services:

| Service | Description |
|---|---|
| **NGINX** | Web server and reverse proxy. Handles all incoming HTTPS traffic (port 443). |
| **WordPress** | Content management system accessible via the browser. |
| **MariaDB** | Database backend used by WordPress to store all site data. |

All services run in isolated Docker containers and communicate through a private Docker network.

---

## Starting and Stopping the Project

### Start the stack

```bash
make
```

This will build all images (if not already built) and start all containers in the background.

### Stop the stack

```bash
make down
```

This stops and removes the running containers, but **preserves your data** (volumes are kept).

### Full cleanup (removes everything including data)

```bash
make fclean
```

> ⚠️ This will delete all containers, images, and volumes. All stored data (database, uploads) will be lost.

---

## Accessing the Website and Administration Panel

### Website

Open your browser and navigate to:

```
https://<your-domain-or-localhost>
```

> The site uses a self-signed TLS certificate. Your browser may show a security warning — this is expected. You can proceed by accepting the exception.

### WordPress Administration Panel

```
https://<your-domain-or-localhost>/wp-admin
```

Log in with the admin credentials defined during setup (see credentials section below).

---

## Managing Credentials

All sensitive credentials (database password, WordPress admin password, etc.) are stored securely and **never committed to the Git repository**.

### Where to find credentials

Credentials are stored in one of the following locations depending on the setup:

- **`.env` file** at the root of the project (excluded from Git via `.gitignore`)
- **Docker secrets files** located in the `secrets/` directory (also excluded from Git)

### Changing credentials

1. Edit the relevant `.env` or secrets file.
2. Rebuild and restart the stack:
   ```bash
   make fclean
   make
   ```

> ⚠️ Changing the database password after initial setup requires manually updating both the MariaDB user and the WordPress configuration.

---

## Checking That Services Are Running

### View running containers

```bash
docker ps
```

All three containers (`nginx`, `wordpress`, `mariadb`) should appear with status `Up`.

### View logs for a specific service

```bash
docker logs <container-name>
```

Examples:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Check NGINX is responding

```bash
curl -k https://localhost
```

A successful response means NGINX is up and routing traffic correctly.

### Check MariaDB is running

```bash
docker exec -it mariadb mariadb -u root -p
```

Enter the root password when prompted. If you get a MariaDB prompt, the database is healthy.


## Checking more in detail


### TSL check

```bash
for tls in 1 1_1 1_2 1_3; do
    echo -n "TLS $tls: "
    openssl s_client -connect thelee.42.fr:443 -servername thelee.42.fr -tls$tls </dev/null 2>/dev/null | grep "Cipher"
done
```

### Connection check

```bash
curl -k -I https://thelee.42.fr/ 
curl -vI https://thelee.42.fr/
openssl s_client -tls1_2 thelee.42.fr:443
```


