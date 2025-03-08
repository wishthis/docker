#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Configure hostname for email functionality
echo "$(hostname -i) $(hostname) $(hostname).localhost" >> /etc/hosts

# Start Sendmail service in background
service sendmail start

# Clean up pre-existing Apache PID files to prevent startup issues
if [ -f /var/run/apache2/apache2.pid ]; then
  rm -f /var/run/apache2/apache2.pid
fi

# Security: Remove www-data from sudoers if present
if id -nG www-data | grep -qw "sudo"; then
  deluser www-data sudo
fi

# Execute the CMD instruction from Dockerfile
exec "$@"

