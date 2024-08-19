# archives_online
Archives Online, an application supporting discovery of archival materials, based on ArcLight

* Arclight *
A Rails engine supporting discovery of archival materials, based on Blacklight


# Getting Started

- [Docker (Recommended)](#docker)
- [Locally without Docker](#locally-without-docker)
- [Kubernetes](#kubernetes)

## Docker

*Note: You may need to add your user to the "docker" group:*

```bash
sudo gpasswd -a $USER docker
newgrp docker
```

### Installation

1) **Clone the repository and checkout the last release:**

    ```bash
    git clone git@github.com:scientist-softserv/archives_online.git
    cd archives_online
    ```

2) **Set up DNS:**

    #### Dory Installation

    ```bash
    gem install dory
    dory up
    ```

3) **Build the Docker images:**

    ```bash
    docker compose build
    ```
### Configuration

archives_online configuration is primarily found in the `.env` file, which will get you running out of the box.

### Running the Application

#### Starting

```bash
docker compose up
```

It will take some time for the application to start up, and a bit longer if it's the first startup. When you see `Passenger core running in multi-application mode.` or `Listening on tcp://0.0.0.0:3000` in the logs, the application is ready.

If you used Dory, the application will be available from the browser at `http://archives-online.test`.

**You are now ready to start using archives_online!**

#### Stopping

```bash
docker compose down
```

### Testing

The full spec suite can be run in docker locally. There are several ways to do this, but one way is to run the following:

#### In Docker
```bash
docker compose exec web bash
bundle exec rake
```

#### Without Docker
```bash
bundle exec rake
```

## Locally without Docker

Please note that this is unused by SoftServ

### Compatibility

* Ruby 3.0.3 or later
* Rails 7.0 or later
* Solr 8.1 or later

```bash
solr_wrapper
bundle exec rails server -b 0.0.0.0
```

## Kubernetes

archives_online relies on helm charts for deployment to kubernetes containers. We also provide a basic helm [deployment script](/bin/helm_deploy). archives_online currently needs some additional volumes and ENV vars over the base Blacklight application.


## Ingesting Data

### EAD Files

#### In Docker
There are 2 files pre-loaded and in order to run them you need to be inside the web container:
```
docker compose exec web bash
bundle exec traject -u http://solr:8983/solr/${SOLR_CORE} -i xml -c lib/arclight/traject/ead2_config.rb data/VAD8042.xml
bundle exec traject -u http://solr:8983/solr/${SOLR_CORE} -i xml -c lib/arclight/traject/ead2_config.rb data/InU-Li-VAD1572.xml
```

#### Without Docker
```
bundle exec traject -u http://solr:8983/solr/${SOLR_CORE} -i xml -c lib/arclight/traject/ead2_config.rb data/VAD8042.xml
bundle exec traject -u http://solr:8983/solr/${SOLR_CORE} -i xml -c lib/arclight/traject/ead2_config.rb data/InU-Li-VAD1572.xml
```
