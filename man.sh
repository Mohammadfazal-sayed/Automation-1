ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`
sleep 60
ssh -i "/home/ubuntu/Jenkins1.pem" ubuntu@172.31.21.233 '
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC58eb5Qb2m9BPOuIjKu6Pm1InP35nzTH8/Yy93CC/kaKHR5WTXsjGMFK6chOQLq17MZPei7frZdyCZHu1CzKgKi+rIs0IBcu4rye51ZFh0rgFLk9qpspXmUBTJKroppaTf2/K/04yW0SLT/zmzdnwrhI+QkOab3xfbTs7KehChXnnkOlR9ULfTre3o/XGcLRju9eaYbUamokwhpgxYHc9O4WYp59jokf0d61cmhTsE0ODZJNt3Qju5m1cfAZ1irmA6UO+DN4WYiexFIBIweWe5e7OzoN/ko4quqkcoYazXoeuEwBYEi7OZRK2Ykkb/Nz741Ry/a+47d60mub31iuiL jenkins@jenkinsServer" >> /home/ubuntu/.ssh/authorized_keys
sudo ufw allow 22
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
'

ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`
ssh -i "/home/ubuntu/Jenkins1.pem" ubuntu@172.31.19.25 '
sudo mysql -u root -e "CREATE USER '"'slave09'"'@'"'172.31.21.233'"' IDENTIFIED BY '"'Shivasali@16'"';"
sudo mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO '"'slave09'"'@'"'$ipr'"';"
sudo systemctl restart mysql
sudo mysqldump -u root --all-databases --master-data > masterdump07.sql
scp -o StrictHostKeyChecking=no masterdump07.sql '172.31.21.233':
'
ip=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PublicIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ipr=`aws ec2 describe-instances  --region us-east-1 --query 'sort_by(Reservations[].Instances[], &LaunchTime)[].[InstanceId,PrivateIpAddress,LaunchTime]' --output text | tail -1 | awk '{ print  $2 }'`

ssh -i "/home/ubuntu/Jenkins1.pem" ubuntu@172.31.21.233 ' 
sudo systemctl restart mysql
sudo mysql -u root -e "STOP SLAVE;"
sudo mysql -u root -e "CHANGE MASTER TO MASTER_HOST ='"'172.31.19.25'"', MASTER_USER ='"'slave09'"', MASTER_PASSWORD ='"'Shivasali@16'"';"
sudo mysql -u root < masterdump07.sql
sudo mysql -u root -e "START SLAVE;"
'
