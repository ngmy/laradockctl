#!/bin/bash
set -Ceuo pipefail

local NAME='my:up'
local DESCRIPTION='Start up my development environment'

handle() {
  # Enable assertion in the php-fpm container
  # Restore php.ini
  sed -i \
    -e '/zend.assertions = 1/d' \
    -e '/assert.exception = On/d' \
    php-fpm/laravel.ini
  # Modify php.ini
  sed -i \
    -e '$a zend.assertions = 1' \
    -e '$a assert.exception = On' \
    php-fpm/laravel.ini

  # Copy my environment variables file to .env
  if [ -n "${LARADOCKCTL_ENV_FILE:-}" ]; then
    cp -f "${LARADOCKCTL_ENV_FILE}" .env
  fi

  # Start up containers
  local CONTAINERS
  CONTAINERS="$(echo -n "${LARADOCKCTL_CONTAINERS:-workspace}" | xargs -d ',')"
  docker-compose up -d --build ${CONTAINERS}

  # Enable assertion in the workspace container
  docker-compose exec workspace bash -c 'sed -i \
    -e "s/zend.assertions = -1/zend.assertions = 1/" \
    -e "s/;assert.exception = On/assert.exception = On/" \
    /etc/php/7.4/cli/php.ini'

  # Generate tool configuration files from templates
  if [ -f ../.php_cs.dist ]; then
    docker-compose exec -u laradock workspace cp .php_cs.dist .php_cs
  fi
  if [ -f ../phpcs.xml.dist ]; then
    docker-compose exec -u laradock workspace cp phpcs.xml.dist phpcs.xml
  fi
  if [ -f ../phpdoc.dist.xml ]; then
    docker-compose exec -u laradock workspace cp phpdoc.dist.xml phpdoc.xml
  fi
  if [ -f ../phpstan.neon.dist ]; then
    docker-compose exec -u laradock workspace cp phpstan.neon.dist phpstan.neon
  fi
  if [ -f ../phpunit.xml.dist ]; then
    docker-compose exec -u laradock workspace cp phpunit.xml.dist phpunit.xml
  fi
  if [ -f ../psalm.xml.dist ]; then
    docker-compose exec -u laradock workspace cp psalm.xml.dist psalm.xml
  fi

  # Install PHIVE
  if ! docker-compose exec workspace bash -c 'test -f /usr/local/bin/phive'; then
    docker-compose exec workspace curl -fsSL https://phar.io/releases/phive.phar -o /tmp/phive.phar
    docker-compose exec workspace curl -fsSL https://phar.io/releases/phive.phar.asc -o /tmp/phive.phar.asc
    docker-compose exec workspace gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys 0x9D8A98B29B2D5D79
    docker-compose exec workspace gpg --verify /tmp/phive.phar.asc /tmp/phive.phar
    docker-compose exec workspace chmod +x /tmp/phive.phar
    docker-compose exec workspace mv /tmp/phive.phar /usr/local/bin/phive
  fi
  # Install tools
  if [ -f ../.phive/phars.xml ]; then
    set +o pipefail
    yes | laradockctl my:phive install --force-accept-unsigned
    set -o pipefail
  fi
  # Extract tools
  if docker-compose exec -u laradock workspace composer run-script -l | grep phar-extractor >/dev/null; then
    docker-compose exec -u laradock workspace composer phar-extractor
  fi

  # Install dependencies
  if [ -f ../composer.json ]; then
    docker-compose exec -u laradock workspace composer install
  fi
}
