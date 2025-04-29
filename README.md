# archives_online
Archives Online, an application supporting discovery of archival materials, based on ArcLight

*Arclight*
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
    git clone git@github.com:notch8/archives_online.git
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

Please note that this is unused by Notch8

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

Run this command in the container to create works

```
DIR=data rake arclight:index_dir
```

## Setup in k8 env

### Creating solr collections in k8 env with zookeeper

```
curl -X POST "http://admin:$SOLR_ADMIN_PASSWORD@solr.solr:8983/solr/admin/collections?action=CREATE&name=archives-online&numShards=2&collection.configName=archives-online"
```

## Debugging

To use a debugger, create a `docker-compose.override.yml` file with the following contents

```
services:
  web:
    environment:
      - VIRTUAL_HOST=archives-online.test
      - VIRTUAL_PORT=3000
    command: sleep infinity
    volumes:
    - .:/home/app/webapp
    - ./generate-init.sh:/home/app/webapp/generate-init.sh
```

Manually start the application and go into docker's bash:

`docker compose up -d && docker compose exec web bash`

To use the debugger command, you may need to add the following to the file:

`require 'debug'; debugger`

### Overriding Arclight Views

The Arclight gem uses [Rails ViewComponent](https://viewcomponent.org/) to build markup. ViewComponents pair a Ruby component class with a corresponding markup file.

For example:

```plaintext
arclight
  └──app
    └── components
      └── arclight
        ├── bookmark_component.html.erb
        └── bookmark_component.rb
```


It is often necessary to override views in the Arclight gem to modify the look or behavior of the archives_online application. To override a view, create files of the same name in `archives_online/app/components/ngao/arclight`.

```plaintext
archives_online
  └──app
    └── components
        └── ngao
          └── arclight
            ├── bookmark_component.html.erb
            └── bookmark_component.rb
```

The Ruby class will follow the pattern:

```ruby
module Ngao
  module Arclight
    class BookmarkComponent < ::Arclight::BookmarkComponent
    end
  end
end
```

Methods can be added to modify behavior as needed. If no behavior change is needed the class with inherit functionality from the Arclight gem.

View files will need to be copied in their entirety then modified as need.

Call the Ruby file in the `catalog_controller.rb` file to instantiate the class.

```ruby
config.show.bookmark_component = Ngao::Arclight::BookmarkComponent
```

Please note the Arclight version and what is being added or removed in the override in the file. This allows for clear communication and to more easily manage Arclight gem updates.

```
# OVERRIDE Arclight v1.4.0 to <your change here>
```
