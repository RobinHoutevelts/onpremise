# Sentry 10 On-Premise [![Build Status][build-status-image]][build-status-url]

Official bootstrap for running your own [Sentry](https://sentry.io/) with [Docker](https://www.docker.com/).

### This is a [Wieni](https://www.wieni.be) fork. Use at own risk

This fork uses postgres 10 because we ran Sentry 9.1.2 on it and had trouble downgrading our database 😅.

## Requirements

 * Docker 17.05.0+
 * Compose 1.23.0+

## Minimum Hardware Requirements:

 * You need at least 2400MB RAM

## Setup

To get started with all the defaults, simply clone the repo and run `./install.sh` in your local check-out.

There may need to be modifications to the included example config files (`sentry/config.example.yml` and `sentry/sentry.conf.example.py`) to accommodate your needs or your environment (such as adding GitHub credentials). If you want to perform these, do them before you run the install script and copy them without the `.example` extensions in the name (such as `sentry/sentry.conf.py`) before running the `install.sh` script.

The recommended way to customize your configuration is using the files below, in that order:

 * `config.yml`
 * `sentry.conf.py`
 * `.env` w/ environment variables

We currently support a very minimal set of environment variables to promote other means of configuration.

If you have any issues or questions, our [Community Forum](https://forum.sentry.io/c/on-premise) is at your service! Everytime you run the install script, it will generate a log file, `sentry_install_log-<ISO_TIMESTAMP>.txt` with the output. Sharing these logs would help people diagnose any issues you might be having.

## Versioning

We continously push the Docker image for each commit made into [Sentry](https://github.com/getsentry/sentry), and other services such as [Snuba](https://github.com/getsentry/snuba) or [Symbolicator](https://github.com/getsentry/symbolicator) to [our Docker Hub](https://hub.docker.com/u/getsentry) and tag the latest version on master as `:latest`. This is also usually what we have on sentry.io and what the install script uses. You can use a custom Sentry image, such as a modified version that you have built on your own, or simply a specific commit hash by setting the `SENTRY_IMAGE` environment variable to that image name before running `./install.sh`:

```shell
SENTRY_IMAGE=getsentry/sentry:10 ./install.sh
```

or

```shell
SENTRY_IMAGE=getsentry/sentry:83b1380 ./install.sh
```

If you want to use different or specific images for other services, you may create a `docker-compose.overrides.yaml` file in the repo and override the `image` field for the corresponding services.

We strongly recommend keeping the `latest` tags for all, if you are using this repository directly. We also recommend using specific commit tags if you are consuming any of our Docker images in an environment that needs consistent deploys such as [a Helm chart](https://github.com/helm/charts/tree/master/stable/sentry).

## Event Retention

Sentry comes with a cleanup cron job that prunes events older than `90 days` by default. If you want to change that, you can change the `SENTRY_EVENT_RETENTION_DAYS` environment variable in `.env` or simply override it in your environment. If you do not want the cleanup cron, you can remove the `sentry-cleanup` service from the `docker-compose.yml`file.

## Securing Sentry with SSL/TLS

If you'd like to protect your Sentry install with SSL/TLS, there are
fantastic SSL/TLS proxies like [HAProxy](http://www.haproxy.org/)
and [Nginx](http://nginx.org/). You'll likely want to add this service to your `docker-compose.yml` file.

## Updating Sentry

_You need to be on at least Sentry 9.1.2 to be able to upgrade automatically to the latest version. If you are not, upgrade to 9.1.2 first by checking out the [9.1.2 tag](https://github.com/getsentry/onpremise/tree/9.1.2) on this repo._

The included `install.sh` script is meant to be idempotent and to bring you to the latest version. What this means is you can and should run `install.sh` to upgrade to the latest version available. Remember that the output of the script will be stored in a log file, `sentry_install_log-<ISO_TIMESTAMP>.txt`, which you may share for diagnosis if anything goes wrong.

### Upgrade steps

First you need to have a database dump ready and place it in the `sentry-init-db` directory.

You can't just go ahead and run the `./install.sh` command because the database-container will take too long to bootstrap.
So we'll have to prepare things first.

 - `docker-compose build --force-rm`
 - `docker volume create --name=sentry-postgres`
 - `docker volume create --name=sentry-data`
 - `docker volume create --name=sentry-redis`
 - `docker volume create --name=sentry-zookeeper`
 - `docker volume create --name=sentry-kafka`
 - `docker volume create --name=sentry-kafka`
 - `docker volume create --name=sentry-clickhouse`
 - `docker volume create --name=sentry-symbolicator`
 - `docker-compose run postgres`
 
   - Since this is a fresh instance it won't have a database and will look for a dump in the `sentry-init-db`
      - If you messed up and need to run it again you'll have to remove the container volume and recreate it
        - `docker volume rm sentry-postgres`
           - It's possible this is still linked to a container, so stop and remove those first
              - `docker container ls | grep sentry_onpremise_postgres`
              - `docker stop sentry_onpremise_postgres_run_xxx`
              - `docker container rm sentry_onpremise_postgres_run_xxx`
        - `docker volume create --name=sentry-postgres`
   - You'll get a message saying 'database system is ready to accept connections' or smth like that
   - When done just `ctrl+c` out of there
   - It's possible you have a lingering container afterwards
     - `docker ps | grep sentry_onpremise_postgres_run`
     - Kill that too
       - `docker stop sentry_onpremise_postgres_run_xxx`
       - `docker container rm sentry_onpremise_postgres_run_xxx`

Finally you are ready to run the `./install.sh` script.

This can take a while 😅. It will run the upgrade script and perform any necessary migrations.
But afterwards you'll be running v10 of Sentry 🥳

## Handy commands:

- `docker exec -it sentry_onpremise_postgres_1 pg_dump -U postgres postgres > db.sql`

## Resources

 * [Documentation](https://docs.sentry.io/server/)
 * [Bug Tracker](https://github.com/getsentry/onpremise/issues)
 * [Forums](https://forum.sentry.io/c/on-premise)
 * [Discord](https://discord.gg/mg5V76F) (Sentry Community, #sentry-server)


[build-status-image]: https://api.travis-ci.com/getsentry/onpremise.svg?branch=master
[build-status-url]: https://travis-ci.com/getsentry/onpremise
