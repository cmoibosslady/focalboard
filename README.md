# Focalboard on Raspberry Pi 5 — Docker Setup

A self-hosted [Focalboard](https://www.focalboard.com/) server running inside Docker on a **Raspberry Pi 5** (ARM64 / aarch64).  
Friends can connect from outside your home network once you forward the right port on your router.

---

## Repository layout

```
.
├── Dockerfile                  # Multi-arch build from source (optional)
├── docker-compose.yml          # Quick-start: single container, SQLite storage
├── docker-compose.nginx.yml    # Production: Focalboard + PostgreSQL + Nginx
├── config/
│   └── focalboard.json         # Focalboard server configuration
├── nginx/
│   └── nginx.conf              # Nginx reverse-proxy configuration
└── .env.example                # Environment variables template
```

---

## Quick-start (SQLite, single container)

This is the simplest way to get started.  Data is stored in an SQLite file inside a Docker volume.

```bash
# 1. Clone the repo
git clone https://github.com/cmoibosslady/focalboard.git
cd focalboard

# 2. (Optional) Customise the server root URL
cp .env.example .env
#    → edit FOCALBOARD_SERVER_ROOT to your Pi's LAN IP, e.g. http://192.168.1.42:8000

# 3. Start Focalboard
docker compose up -d

# 4. Open in browser
#    Local:   http://localhost:8000
#    Network: http://<raspberry-pi-ip>:8000
```

---

## Production setup (PostgreSQL + Nginx reverse proxy)

Use this when you want a more robust database and a proper HTTP server in front of Focalboard (also required for HTTPS / external access).

```bash
# 1. Copy and edit the environment file
cp .env.example .env
#    → set FOCALBOARD_SERVER_ROOT to your HTTPS URL
#    → set a strong POSTGRES_PASSWORD

# 2. Create local TLS certs (works offline, no public internet required)
mkdir -p nginx/certs
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout nginx/certs/privkey.pem \
  -out nginx/certs/fullchain.pem \
  -subj "/CN=<raspberry-pi-ip-or-local-hostname>"

# 3. Update config/focalboard.json to use PostgreSQL
#    Change "dbtype" to "postgres" and set "dbconfig" to match your credentials.

# 4. Start the stack
docker compose -f docker-compose.nginx.yml up -d
```

Focalboard will be reachable on **https://<raspberry-pi-ip>** via Nginx (port 443).  
Port 80 redirects to HTTPS automatically.

---

## Accessing from outside your home network

To let friends connect from the internet you need to:

1. **Find your Pi's local IP address**
   ```bash
   hostname -I | awk '{print $1}'
   ```

2. **Forward a port on your router**  
   Log in to your router and add a port-forwarding rule:
   | External port | Internal IP | Internal port | Protocol |
   |---------------|-------------|---------------|----------|
   | 8000 (or 80)  | \<Pi LAN IP\> | 8000 (or 80)  | TCP      |

3. **Find your public IP**  
   ```bash
   curl -s https://api.ipify.org
   ```
   Your friends can then open `http://<your-public-ip>:8000`.

4. *(Recommended)* **Use a Dynamic DNS (DDNS) service** such as [DuckDNS](https://www.duckdns.org/) or [No-IP](https://www.noip.com/) so the URL stays the same even if your ISP changes your IP.

5. *(Recommended for internet exposure)* Replace self-signed certs with a trusted certificate (for example [Let's Encrypt](https://letsencrypt.org/)).

---

## Building the image locally (optional)

The Dockerfile supports multi-arch builds via `docker buildx`.  
This is only needed if you want to customise the image rather than use the official `mattermost/focalboard` image.

```bash
# Build for Raspberry Pi 5 (ARM64)
docker buildx build \
  --platform linux/arm64 \
  -t focalboard:local \
  --load .

# Run the locally built image
docker run -d \
  -v fbdata:/opt/focalboard/data \
  -p 8000:8000 \
  focalboard:local
```

---

## Configuration reference

Edit `config/focalboard.json` to customise the server behaviour.

| Key | Default | Description |
|-----|---------|-------------|
| `serverRoot` | `http://localhost:8000` | Public URL used in e-mails / links |
| `port` | `8000` | Port the Go server listens on inside the container |
| `dbtype` | `sqlite3` | `sqlite3` or `postgres` |
| `dbconfig` | `./data/focalboard.db` | SQLite path or PostgreSQL DSN |
| `useSSL` | `false` | Enable TLS directly on the Go server (not needed behind Nginx) |
| `localOnly` | `false` | Set to `true` to block all remote connections |
| `telemetry` | `true` | Send anonymous usage data to Mattermost |

---

## Useful commands

```bash
# View logs
docker compose logs -f focalboard

# Stop the stack
docker compose down

# Back up data volume
docker run --rm -v fbdata:/data -v $(pwd):/backup alpine \
  tar czf /backup/focalboard-backup.tar.gz -C /data .

# Restore from backup
docker run --rm -v fbdata:/data -v $(pwd):/backup alpine \
  tar xzf /backup/focalboard-backup.tar.gz -C /data
```
