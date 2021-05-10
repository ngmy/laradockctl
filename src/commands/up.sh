#!/bin/bash
#
# The laradockctl command to start up a development environment.

set -Ceuo pipefail

local NAME='up'
local DESCRIPTION='Start up a development environment'

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
  local -r container_names="$(echo -n "${LARADOCKCTL_CONTAINER_NAMES:-workspace}" | xargs -d ',')"
  docker-compose up -d --build ${container_names}

  # Enable assertion in the workspace container
  docker-compose exec workspace bash -c 'sed -i \
    -e "s/zend.assertions = -1/zend.assertions = 1/" \
    -e "s/;assert.exception = On/assert.exception = On/" \
    /etc/php/7.4/cli/php.ini'

  # Generate tool configuration files from templates
  if file_exists_in_workspace .php_cs.dist; then
    docker-compose exec -u laradock workspace cp .php_cs.dist .php_cs
  fi
  if file_exists_in_workspace phpcs.xml.dist; then
    docker-compose exec -u laradock workspace cp phpcs.xml.dist phpcs.xml
  fi
  if file_exists_in_workspace phpdoc.dist.xml; then
    docker-compose exec -u laradock workspace cp phpdoc.dist.xml phpdoc.xml
  fi
  if file_exists_in_workspace phpstan.neon.dist; then
    docker-compose exec -u laradock workspace cp phpstan.neon.dist phpstan.neon
  fi
  if file_exists_in_workspace phpunit.xml.dist; then
    docker-compose exec -u laradock workspace cp phpunit.xml.dist phpunit.xml
  fi
  if file_exists_in_workspace psalm.xml.dist; then
    docker-compose exec -u laradock workspace cp psalm.xml.dist psalm.xml
  fi

  # Install PHIVE
  if ! file_exists_in_workspace /usr/local/bin/phive; then
    docker-compose exec workspace curl -fsSL https://phar.io/releases/phive.phar -o /tmp/phive.phar
    docker-compose exec workspace curl -fsSL https://phar.io/releases/phive.phar.asc -o /tmp/phive.phar.asc
    docker-compose exec workspace gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys 0x9D8A98B29B2D5D79
    docker-compose exec workspace gpg --verify /tmp/phive.phar.asc /tmp/phive.phar
    docker-compose exec workspace chmod +x /tmp/phive.phar
    docker-compose exec workspace mv /tmp/phive.phar /usr/local/bin/phive
  fi
  # Install tools
  if file_exists_in_workspace .phive/phars.xml; then
    set +o pipefail
    yes | laradockctl phive install --force-accept-unsigned
    set -o pipefail
  fi
  # Extract tools
  if docker-compose exec -u laradock workspace composer run-script -l | grep phar-extractor >/dev/null; then
    docker-compose exec -u laradock workspace composer phar-extractor
  fi

  # Install dependencies
  if file_exists_in_workspace composer.json; then
    docker-compose exec -u laradock workspace composer install
  fi
}
