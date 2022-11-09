#!/bin/bash

# Enabling and configure Hostname and Sendmail for MJML
## Add hostname
sudo bash -c "echo '$(hostname -i) $(hostname) $(hostname).localhost' >> /etc/hosts"

## Launch Sendmail service
sudo service sendmail start

# Remove Apache pre-existing PID files
sudo rm -f /var/run/apache2/apache2.pid

# Removing www-data from sudoers
sudo deluser www-data sudo

# Start Apache (CMD)
exec "$@"
