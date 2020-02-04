#!/bin/bash -e
. /opt/bitnami/base/functions

print_welcome_page

INIT_SEM=/tmp/initialized.sem

fresh_container() {
  [ ! -f $INIT_SEM ]
}

app_present() {
  [ -f /app/config/database.php ]
}

vendor_present() {
  [ -d /app/vendor ]
}

wait_for_db() {
  local db_host="${DB_HOST:-mariadb}"
  local db_port="${DB_PORT:-3306}"
  local db_address=$(getent hosts "$db_host" | awk '{ print $1 }')
  counter=0
  log "Connecting to mariadb at $db_address"
  while ! curl --silent "$db_address:$db_port" >/dev/null; do
    counter=$((counter+1))
    if [ $counter == 30 ]; then
      log "Error: Couldn't connect to mariadb."
      exit 1
    fi
    log "Trying to connect to mariadb at $db_address. Attempt $counter."
    sleep 5
  done
}

setup_db() {
  log "Configuring the database"
  sed -i "s/utf8mb4/utf8/g" /app/config/database.php
  php artisan migrate --force
}

if [ "${1}" == "php" -a "$2" == "artisan" -a "$3" == "serve" ]; then
  if ! app_present; then
    log "Creating laravel application"
    cp -a /tmp/app/. /app/
    log "laravel application created"

  fi

  log "Installing/Updating Laravel dependencies (composer)"
  if fresh_container; then
    log "installing laravel dependencies"
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
    composer require encore/laravel-admin
    php artisan vendor:publish --provider="Encore\Admin\AdminServiceProvider"
    php artisan admin:install
    # set lang to zh-CN
    composer require caouecs/laravel-lang
    sed -i "s/'locale' => 'en'/'locale' => 'zh-CN'/g" /app/config/app.php
    # install helper plugin
    composer require laravel-admin-ext/helpers
    php artisan admin:import helpers
    # install log-viewer plugin
    composer require laravel-admin-ext/log-viewer
    php artisan admin:import log-viewer
    
    sed -i "s/DB_HOST=127.0.0.1/DB_HOST=mysql/g" /app/.env
    sed -i "s/DB_PASSWORD=/DB_PASSWORD=my_password/g" /app/.env
    log "Dependencies installed with auth"
  else
    log "uncomment following two lines if you want to update dependencies"
    #composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
    #composer update
    log "Dependencies updated"
  fi

  wait_for_db

  if ! fresh_container; then
    echo "#########################################################################"
    echo "                                                                         "
    echo " App initialization skipped:                                             "
    echo " Delete the file $INIT_SEM and restart the container to reinitialize     "
    echo " You can alternatively run specific commands using docker-compose exec   "
    echo " e.g docker-compose exec myapp php artisan make:console FooCommand       "
    echo "                                                                         "
    echo "#########################################################################"
  else
    setup_db
    log "Initialization finished"
    touch $INIT_SEM
  fi
fi

exec tini -- "$@"
