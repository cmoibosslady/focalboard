# Focalboard on Raspberry Pi 5 — Docker Setup

A self-hosted [Focalboard](https://www.focalboard.com/) server running inside Docker on a **Raspberry Pi 5** (ARM64 / aarch64).    
Friends connection was enabled using netbird reverse proxy beta service, linking a public url adress to the raspberry. Data is stored inside a USB linked device (key in my case but disk sould work too).   
One focalboard server is equal to one focalboard, not multiple board in one server. So that's why nginx is implemented. To be able to have possibly multiple boards in one point.

#### Project architecture

``` bash
.
├── docker-compose.yml
├── secrets
│   └── postgres_credentials.txt // create this file from the example
└── src
    └── requirements
        ├── focalboard
        │   ├── config.json
        │   └── Dockerfile
        ├── nginx
        │   ├── Dockerfile
        │   └── nginx.conf
        └── postgresql
            ├── Dockerfile
            ├── initdb.sh
            └── initdb.sql
```
For security reasons, credentials (db name, user, password...) are only available in the secrets directory and are transferred to postgresql and focalboard by Docker secrets as env variables.

#### Things to add for security

The ssl certificate are self-signed meaning HTTPS connection is not fully secured and MIM attack can still happen. Nginx container should be fiddle with in order to allow full HTTPS secure connection.   
For personnal use, I use [netbird](https://docs.netbird.io/manage/reverse-proxy) reverse proxy beta version to access the focalboard from anyplace.


#### Things to change about database
Delete focalboard-database since it's not used currently by the program.

#### How to use

```bash
# Build and run the project
docker compose up -d

# View logs
docker compose logs -f focalboard

# Stop the stack
docker compose down
```

#### How to backup Postgresql database
First, reach into the container running the postgresql database (named postgresql by default)
```bash
docker exec -it postgresql sh
```
Then use [pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html) to save the database. Choose between custom format (for restauration with pg_restore) or a readable sql file.
```bash
pg_dump -U [name of database user] -h localhost -p 5432 -F c -b -v -f [file path to store the backup] [name of database]
```

```bash
pg_dump -U [name of database user] -h localhost -p 5432 -F p -b -v -f [file path to store the backup] [name of database]
```


#### Credits

For the focalboard server on RaspberryPiOS, credits to : [jimmymasaru](https://github.com/jimmymasaru/focalboard-docker-arm)
