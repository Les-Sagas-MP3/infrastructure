# Les Sagas MP3 - Infrastructure

## Preparation

Before running the installation, customize the following files.

 - `core/application.properties` :

```properties
spring.datasource.password=<Password for LSM database>
jwt.secret=<A random salt for JWT auth>
```

 - `db/install_db.sh` :

```bash
[...]
LSM_DB_PASSWORD="<Password for LSM database>"
[...]
```

## Installation

```bash
./install.sh
```