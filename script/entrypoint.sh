#!/bin/bash

# Enabling and configure Hostname and Sendmail for MJML
## Add hostname
sudo bash -c "echo '$(hostname -i) $(hostname) $(hostname).localhost' >> /etc/hosts"

## Laucnh Sendmail
sudo service sendmail start

# Remove Apache pre-existing PID files
sudo rm -f /var/run/apache2/apache2.pid

# Start Apache (CMD)
exec "$@"
