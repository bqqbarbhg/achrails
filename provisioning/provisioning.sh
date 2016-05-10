#!/usr/bin/env bash

#
# This script installs the development environment.
#

# Exit on first error.
set -e

# Set up environment variables if passed on from Vagrant
if [ -n "$ACHRAILS_OIDC_CLIENT_URL" ]; then
    echo "Found Achrails oidc client url: $ACHRAILS_OIDC_CLIENT_URL"
    echo "ACHRAILS_OIDC_CLIENT_URL=$ACHRAILS_OIDC_CLIENT_URL" | sudo tee -a /etc/environment > /dev/null
fi

if [ -n "$ACHRAILS_OIDC_CLIENT_ID" ]; then
    echo "Found Achrails oidc client id: $ACHRAILS_OIDC_CLIENT_ID"
    echo "ACHRAILS_OIDC_CLIENT_ID=$ACHRAILS_OIDC_CLIENT_ID" | sudo tee -a /etc/environment > /dev/null
fi

if [ -n "$ACHRAILS_OIDC_CLIENT_SECRET" ]; then
    echo "Found Achrails oidc client secret: $ACHRAILS_OIDC_CLIENT_SECRET"
    echo "ACHRAILS_OIDC_CLIENT_SECRET=$ACHRAILS_OIDC_CLIENT_SECRET" | sudo tee -a /etc/environment > /dev/null
fi

# Require all variables to be set
set -u

LOG='/vagrant/provisioning/provisioning.log'

POSTGRES_CONFIG='/etc/postgresql/9.3/main/pg_hba.conf'

RBENV_REPO='https://github.com/sstephenson/rbenv.git'
RUBY_BUILD_REPO='https://github.com/sstephenson/ruby-build.git'

RUBY_VERSION=$(awk '{$1=$1};1' < /vagrant/.ruby-version)

# Clear the log
> $LOG

# A quiet unattended installation
export DEBIAN_FRONTEND=noninteractive

echo 'Now provisioning! Why not get a coffee?'
echo "Output and errors are logged into ${LOG}."

echo 'Configuring the system...'

# Set a proper locale
echo 'LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/environment > /dev/null

echo 'Upgrading the system...'

sudo apt-get -qy update &>> $LOG
sudo apt-get -qy upgrade &>> $LOG

echo 'Installing utilities...'

sudo apt-get -qy install git-core &>> $LOG

echo 'Installing Postgres...'

sudo apt-get -qy install postgresql postgresql-contrib libpq-dev &>> $LOG

# Allow login from anywhere
sudo sed -Ei \
  's/local\s+all\s+postgres\s+peer/local all postgres trust/' $POSTGRES_CONFIG

sudo service postgresql restart &>> $LOG

echo "Installing Ruby ${RUBY_VERSION}..."

# Common Ruby dependencies
sudo apt-get -qy install autoconf bison build-essential libssl-dev \
  libyaml-dev libsqlite3-dev libreadline6-dev zlib1g-dev libncurses5-dev \
  &>> $LOG

if [ ! -e ~/.rbenv ]; then
  git clone $RBENV_REPO ~/.rbenv &>> $LOG
  git clone $RUBY_BUILD_REPO ~/.rbenv/plugins/ruby-build &>> $LOG

  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

  ~/.rbenv/bin/rbenv install $RUBY_VERSION &>> $LOG
  ~/.rbenv/bin/rbenv global $RUBY_VERSION &>> $LOG
fi

echo 'Installing Bundler...'

~/.rbenv/shims/gem install bundler &>> $LOG

echo 'Installing gems...'

~/.rbenv/shims/bundle install --gemfile="/vagrant/Gemfile" &>> $LOG

echo 'Setting up database...'

DB_ERROR='...createdb failed, skipping. Does the database exist already?'

sudo -u postgres createdb development &>> $LOG || echo $DB_ERROR
sudo -u postgres createdb test &>> $LOG || echo $DB_ERROR

# Set up the database if the schema exists.
if [ -e /vagrant/db/schema.rb ]; then
  ~/.rbenv/shims/rake db:setup --rakefile="/vagrant/Rakefile" &>> $LOG
else
  echo '...no schema, skipping migrations.'
fi

echo 'Starting Rails...'

# Copy the Upstart job into place and refresh Upstart
sudo cp /vagrant/provisioning/config/rails.conf /etc/init/rails.conf &>> $LOG
sudo chmod +x /etc/init/rails.conf &>> $LOG
sudo initctl reload-configuration &>> $LOG

sudo service rails start &>> $LOG || true

echo 'Done!'
