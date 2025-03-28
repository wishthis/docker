#!/bin/bash
set -e

echo "🚀 Starting Wishthis..."

# Configure hostname for email functionality
echo "📧 Configuring email service..."
echo "$(hostname -i) $(hostname) $(hostname).localhost" >> /etc/hosts

# Configure MTA based on environment variables
if [ "$USE_EXTERNAL_SMTP" = "true" ]; then
    echo "📧 Configuring external SMTP: $MAIL_HOST:$MAIL_PORT"
    export USE_LOCAL_MTA=false
    
    # Create PHP mailer configuration with environment variables
    cat > $WISHTHIS_CONFIG/mail_config.php << EOF
<?php
// Mail configuration generated by entrypoint.sh
return [
    'use_external_smtp' => true,
    'host' => '$MAIL_HOST',
    'port' => $MAIL_PORT,
    'encryption' => '$MAIL_ENCRYPTION',
    'username' => '$MAIL_USERNAME',
    'password' => '$MAIL_PASSWORD',
    'from_address' => '$MAIL_FROM_ADDRESS',
    'from_name' => '$MAIL_FROM_NAME'
];
EOF
else
    echo "📧 Using local MTA (sendmail)"
    export USE_LOCAL_MTA=true
    # Configure sendmail
    echo "sendmail_path=/usr/sbin/sendmail -t -i" > /usr/local/etc/php/conf.d/sendmail.ini
    
    # Create PHP mailer configuration for local sendmail
    cat > $WISHTHIS_CONFIG/mail_config.php << EOF
<?php
// Mail configuration generated by entrypoint.sh
return [
    'use_external_smtp' => false,
    'from_address' => '$MAIL_FROM_ADDRESS',
    'from_name' => '$MAIL_FROM_NAME'
];
EOF
fi

# Clean up pre-existing PID files to prevent startup issues
if [ -f /var/run/apache2/apache2.pid ]; then
  echo "⚠️ Cleaning up stale Apache PID file"
  rm -f /var/run/apache2/apache2.pid
fi

if [ -f /var/run/supervisord.pid ]; then
  echo "⚠️ Cleaning up stale Supervisord PID file"
  rm -f /var/run/supervisord.pid
fi

# Security: Remove www-data from sudoers if requested via env variable
if [ "$REMOVE_SUDO_PRIVILEGES" = "true" ]; then
  if id -nG www-data | grep -qw "sudo"; then
    echo "🔒 Removing sudo privileges from www-data for enhanced security"
    deluser www-data sudo
  fi
fi

# Ensure proper permissions for web directories
echo "📂 Setting correct permissions for web directories..."
chown -R www-data:www-data $WISHTHIS_INSTALL
chown -R www-data:www-data $WISHTHIS_CONFIG

# Create the mail_config.php integration file for Wishthis
if [ ! -f $WISHTHIS_INSTALL/src/mail.php ]; then
  echo "📝 Creating mail integration file..."
  cat > $WISHTHIS_INSTALL/src/mail.php << 'EOF'
<?php
// Mail integration for Wishthis
require_once __DIR__ . '/../vendor/autoload.php';
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

function sendEmail($to, $subject, $body) {
    // Load configuration from config file
    $config = include(__DIR__ . '/config/mail_config.php');
    
    $mail = new PHPMailer(true);
    
    try {
        if ($config['use_external_smtp']) {
            // Configure for external SMTP
            $mail->isSMTP();
            $mail->Host       = $config['host'];
            $mail->Port       = $config['port'];
            
            if (!empty($config['encryption'])) {
                $mail->SMTPSecure = $config['encryption'];
            }
            
            if (!empty($config['username']) && !empty($config['password'])) {
                $mail->SMTPAuth   = true;
                $mail->Username   = $config['username'];
                $mail->Password   = $config['password'];
            }
        } else {
            // Use local sendmail
            $mail->isSendmail();
        }
        
        // Sender and recipient
        $mail->setFrom($config['from_address'], $config['from_name']);
        $mail->addAddress($to);
        
        // Content
        $mail->isHTML(true);
        $mail->Subject = $subject;
        $mail->Body    = $body;
        $mail->AltBody = strip_tags($body);
        
        return $mail->send();
    } catch (Exception $e) {
        error_log("Email sending failed: {$mail->ErrorInfo}");
        return false;
    }
}
EOF
fi

echo "✅ Entrypoint initialization complete"

# Execute the CMD instruction from Dockerfile
exec "$@"

