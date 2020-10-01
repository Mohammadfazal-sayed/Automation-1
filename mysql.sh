
aws ec2 run-instances \
    --image-id ami-0817d428a6fb68645 \
    --instance-type t2.micro \
    --subnet-id subnet-fa5128b7 \
    --security-group-ids sg-0a498ee96e5c360af \
    --associate-public-ip-address \
    --key-name Jenkins \
    --region us-east-1



ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`
sleep 60
ssh -i "/home/ubuntu/Jenkins1.pem" ubuntu@$ip '
sudo apt-get update
sudo apt-get install apache2 -y
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo systemctl restart apache2
sudo apt-get install mysql-server mysql-client -y
sudo systemctl restart mysql
sudo chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "31i server-id              = 4"  /etc/mysql/mysql.conf.d/mysqld.cnf 
sudo sed -i '44d' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "44i bind-address  =  0.0.0.0 "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "107i log_bin = /var/log/mysql/mysql-bin.log "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "108i log_bin_index =/var/log/mysql/mysql-bin.log.index "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "109i relay_log = /var/log/mysql/mysql-relay-bin "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "110i relay_log_index = /var/log/mysql/mysql-relay-bin.index "  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+tVfp4xgQaulYsXlemafq4gCflf6bJhaa/fL8ldzkyUYwT+/EyU1bPtWxoOzoLk5f2T0C1HGZirXAEEYTfd9xltAt93WD6b0TIH24SPhIvu67bjNOWB52lDEuXpWYgIQ0+rBBGl5QOtaj9NYZuORgjYRLCEQMRWgpVkEg9Tn+eQ4+hcJe876qPxF0rU3m7wRznLaFApSl3mcwKPZyYg2t/h+ku+vUKDgvKnDPQioXtriO3icFarhtr9ZypzQx+85SUPc8wQPMzceO7IW1dkAmt41uvp2Dr5KpsGw1pjB8h+S8KWs1D23HHfSRUAUcnsrl+mIbAgJoMju3zzz1bwBx ubuntu@MYSQLMaster" >> /home/ubuntu/.ssh/authorized_keys
'

ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`
ssh -i "/home/ubuntu/Jenkins1.pem" ubuntu@172.31.19.25 '
sudo mysql -u root -e "CREATE USER '"'slave08'"'@'"'$ipr'"' IDENTIFIED BY '"'Shivasali@16'"';"
sudo mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO '"'slave08'"'@'"'$ipr'"';"
sudo systemctl restart mysql
sudo mysqldump -u root --all-databases --master-data > masterdump07.sql
scp -o StrictHostKeyChecking=no masterdump07.sql '$ip':
'
ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ssh -i "/home/ubuntu/Jenkins1.pem" ubuntu@$ip ' 
sudo systemctl restart mysql
sudo mysql -u root -e "STOP SLAVE;"
sudo mysql -u root -e "CHANGE MASTER TO MASTER_HOST ='"'172.31.19.25'"', MASTER_USER ='"'slave08'"', MASTER_PASSWORD ='"'Shivasali@16'"';"
sudo mysql -u root < masterdump07.sql
sudo mysql -u root -e "START SLAVE;"
'
