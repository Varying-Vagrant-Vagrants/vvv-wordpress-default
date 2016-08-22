# Provision WordPress Stable

# Make a database, if we don't already have one
echo -e "\nCreating database 'wordpress_default' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS wordpress_default"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON wordpress_default.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
if [[ ! -d /srv/log/wordpress-default ]]; then
    mkdir -p /srv/log/wordpress-default
fi
    touch /srv/log/wordpress-default/error.log
    touch /srv/log/wordpress-default/access.log

# Install and configure the latest stable version of WordPress
if [[ ! -d "/srv/www/wordpress-default" ]]; then

  echo "Downloading WordPress Stable, see http://wordpress.org/"
  cd /srv/www/
  curl -L -O "https://wordpress.org/latest.tar.gz"
  noroot tar -xvf latest.tar.gz
  mv wordpress wordpress-default
  rm latest.tar.gz
  cd /srv/www/wordpress-default

  echo "Configuring WordPress Stable..."
  noroot wp core config --dbname=wordpress_default --dbuser=wp --dbpass=wp --quiet --extra-php <<PHP
// Match any requests made via xip.io.
if ( isset( \$_SERVER['HTTP_HOST'] ) && preg_match('/^(local.wordpress.)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(.xip.io)\z/', \$_SERVER['HTTP_HOST'] ) ) {
    define( 'WP_HOME', 'http://' . \$_SERVER['HTTP_HOST'] );
    define( 'WP_SITEURL', 'http://' . \$_SERVER['HTTP_HOST'] );
}

define( 'WP_DEBUG', true );
PHP

  echo "Installing WordPress Stable..."
  noroot wp core install --url=local.wordpress.dev --quiet --title="Local WordPress Dev" --admin_name=admin --admin_email="admin@local.dev" --admin_password="password"

else

  echo "Updating WordPress Stable..."
  cd /srv/www/wordpress-default
  noroot wp core update

fi