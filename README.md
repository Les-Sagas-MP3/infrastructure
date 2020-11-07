# Les Sagas MP3 - Infrastructure

## Preparation

Before running the installation, customize the following files.

 - `core/application.properties` :

```properties
spring.datasource.password=<Password for LSM database>
jwt.secret=<A random salt for JWT auth>
```

 - `conf_instance.sh` :

Modify each variable according to desired infrastructure
 
## Installation

```bash
./install.sh
```
