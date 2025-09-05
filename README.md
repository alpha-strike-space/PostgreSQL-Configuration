# PostgreSQL-Data-Tables
This is the implementation of the database tables and their respective schema. We can't forget about the bouncer which handles transactions across a pooled connection.

## Notable Documentation Sources
https://www.pgbouncer.org/

https://www.postgresql.org/docs/

https://pgdash.io/blog/pgbouncer-connection-pool.html

## Important Notes:
The pgbouncer handles connections on a different port which is then routed internally to the postgresql database. This allows us to set the size of connections we may handle transactions at anyone time. Ths pgbouncer pools transactions and may cache the connections to reconnect to the datbase when restarting. This allows for seamless maintenance on the database without having to reset connections or deal with potentially orphaned processes. 

Please be aware that not every hosting service will provide sudo privileges and it is not necessary for every setup. This documentation is just a template for those trying to set up the service.

# PostgreSQL & PgBouncer Setup (Linux & BSD)

## 1. Install PostgreSQL

### Linux (Ubuntu/Debian)
```sh
sudo apt update
sudo apt install postgresql postgresql-contrib
```
### BSD (FreeBSD example)
```sh
sudo pkg install postgresql15-server
sudo sysrc postgresql_enable=YES
sudo service postgresql initdb
sudo service postgresql start
```

## 2. Install PgBouncer

### Linux
```sh
sudo apt install pgbouncer
```
### BSD
```sh
sudo pkg install pgbouncer
sudo sysrc pgbouncer_enable=YES
```

## 3. Configure PgBouncer

Edit the following files from your repository:

### pool/pgbouncer.ini
```ini
[databases]
; Remove everything with a semicolon when you are ready to run the bouncer service. Otherwise, it will throw an error.
; Make sure to label everything appropriately just like in your environment from docker-compose.yml
your_db_name_here =  host=running_postgresql port=5432 dbname=your_db_name_here user=your_db_user_here password=your_db_password

[pgbouncer]
; Correctly apply the listening address and port for the internal docker or system network
listen_addr = *
listen_port = 6432
; Default for postgresql is the scram-sha-256
; You may get this by using docker exec -it running_postgresql bash to step inside the postgresql container.
; Then, subsquently use psql -U your_user_name your_db_name
; Copying what you see here for the userlist.txt file appropriately by running this command: SELECT usename, passwd FROM pg_shadow;
auth_type = scram-sha-256
auth_file = /etc/pgbouncer/userlist.txt
; Check the types of pooling modes. Transaction is what we do for Alpha-Strike more generally. Many connections opening and closing on a pool.
; Other options: session, transaction, statement
pool_mode = transaction
max_client_conn = 100
default_pool_size = 20
; Better and more readable logging
log_connections = 1
log_disconnections = 1
```

### pool/userlist.txt
```text
"your_db_user_here" "SCRAM-SHA-256$4096:<salt>$<stored_key>$<server_key>"
```
- Populate with your real PostgreSQL users and SCRAM hashes from:  
  ```sql
  SELECT usename, passwd FROM pg_shadow;
  ```

## 4. Apply Database Schema

From your schema directory:

### schema/schema.sql
[Check it out here](https://github.com/alpha-strike-space/PostgreSQL-Configuration/blob/main/schema/schema.sql)

Apply this schema with:
```sh
psql -U your_db_user_here -d your_db_name_here -f schema/schema.sql
```

## 5. Start and Enable Services

### Linux
```sh
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl enable pgbouncer
sudo systemctl start pgbouncer
```

### BSD
```sh
sudo service postgresql start
sudo service pgbouncer start
```

---
