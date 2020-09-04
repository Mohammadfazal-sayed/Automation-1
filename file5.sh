aws ec2 run-instances \
    --image-id ami-0bcc094591f354be2 \
    --instance-type t2.micro \
    --subnet-id subnet-7f879441 \
    --security-group-ids sg-07142950944cc283c \
    --associate-public-ip-address \
    --key-name sbk \
    --region us-east-1

ip=`aws ec2 describe-instances --region us-east-1 --query "Reservations[*].Instances[*].PublicIpAddress" --output=text | tail -1`

ssh -i "/home/ubuntu/sbk.pem" ubuntu@$ip '

sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPL6ykGYTA8XRtdrNLrOUTFRJQrD7mk+BPYChIBjgBvxzSp1qJreOaXSJ0YodpNACjkJd6L7phhIXZAKwJYvvfCJdjietIYRVK2jB5FjOGxVKLEkvRQHw+VqalwHfoGcPNrXiQSqpQuSQlywEvMNRYAOuQ+zHaLeUIfZ8pKTS9m0wodhh1aqZ3V+EfrtGlMM2QMq3fmedHVT6OWSgI08djL2kCp2XqvwbKk2nQtQF4eszkcxzHg0rvnSRV4HKqcK2D6r5HjzqQb1Q/nrYMsH0vUBt5OU+bkO6bK/zkQRz8bMLZnJAnrGc5CuUSX8Cu76jT7wg+ODT7kC/gvu1aF6bf jenkins@ip-172-31-62-247" >> /home/ubuntu/.ssh/authorized_keys 
sudo ufw allow 22
sudo hostname Fazal2
sudo apt-get update
sudo apt-get install nagios-nrpe-server nagios-plugins -y
sudo chmod 777 -R /etc/nagios/
sudo echo " allowed_hosts=127.0.0.1,172.31.63.150" >> /etc/nagios/nrpe.cfg
sudo service nagios-nrpe-server restart 
'

ssh -i "/home/ubuntu/sbk.pem" ubuntu@172.31.63.150 '
sudo chmod 777 -R /usr/local/nagios/
sudo echo " define host {
        use                          linux-server
        host_name                    Fazal2
        alias                        Ubuntu Host
        address                      '$ip'
        register                     1
}
define service {
      host_name                       Fazal2
      service_description             PING
      check_command                   check_ping!100.0,20%!500.0,60%
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}
define service {
      host_name                       Fazal2
      service_description             Check Users
      check_command                   check_local_users!20!50
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}
define service {
      host_name                       Fazal2
      service_description             Local Disk
      check_command                   check_local_disk!20%!10%!/
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}
define service {
      host_name                       Fazal2
      service_description             Check SSH
      check_command                   check_ssh
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}
define service {
      host_name                       Fazal2
      service_description             Total Process
      check_command                   check_local_procs!250!400!RSZDT
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}
" >> /usr/local/nagios/etc/servers/Fazal12.cfg
sudo systemctl restart nagios '
