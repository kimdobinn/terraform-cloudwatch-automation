echo "===== Installing necessary COTS ====="

echo "===== Installing NodeJS / NPM ====="
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

echo "===== Installing PM2 ====="
npm install pm2@latest -g



echo "\n\n\n===== Setting up base system ====="
# Declare service username variable
export SVC_USER=appsvc

echo "===== Creating service user $SVC_USER ====="
adduser $SVC_USER

# Declare application directory variables
export APP_DIR=/home/$SVC_USER


echo -e "\n\n\n===== Setting up ec2-user ssh authorization key ====="
echo '${authorization_key}' >> /home/ec2-user/.ssh/authorized_keys


echo "\n\n\n===== Setting up event-scheduler ====="
# Setup env variables and directories
export ENV_DIR=$APP_DIR/env
export BACKEND_ENV_DIR=$ENV_DIR/respiree-backend

echo "===== Creating env directory ====="
mkdir -p $BACKEND_ENV_DIR

echo "===== Creating event-scheduler env file ====="
echo '${event_scheduler_env}' > $BACKEND_ENV_DIR/event_scheduler.env

# Export event-scheduler application variables / directories
export EVENT_SCHEDULER_FILE_NAME=event-scheduler.zip
export EVENT_SCHEDULER_DIR=$APP_DIR/event-scheduler
export EVENT_SCHEDULER_TMP_DIR=$EVENT_SCHEDULER_DIR-tmp
export DOWNLOADED_EVENT_SCHEDULER_FILE_PATH=$EVENT_SCHEDULER_TMP_DIR/$EVENT_SCHEDULER_FILE_NAME

echo "===== Creating event-scheduler directories ====="
mkdir -p $EVENT_SCHEDULER_DIR
mkdir -p $EVENT_SCHEDULER_TMP_DIR

echo "===== Downloading event-scheduler application for S3 ====="
aws s3 cp s3://respiree-artifact-bucket/$EVENT_SCHEDULER_FILE_NAME $EVENT_SCHEDULER_TMP_DIR/
export EVENT_SCHEDULER_EXTRACTED_DIR=$EVENT_SCHEDULER_TMP_DIR/$(unzip -l $DOWNLOADED_EVENT_SCHEDULER_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_EVENT_SCHEDULER_FILE_PATH -d $EVENT_SCHEDULER_TMP_DIR

echo "===== Changing directory to $EVENT_SCHEDULER_EXTRACTED_DIR to build application ====="
cd $EVENT_SCHEDULER_EXTRACTED_DIR

echo "===== Installing event-scheduler dependencies ====="
npm install --legacy-peer-deps

echo "===== Building event-scheduler ====="
npm run build

echo "===== Moving built files from tmp directory to actual directory ====="
mv node_modules $EVENT_SCHEDULER_DIR
mv dist $EVENT_SCHEDULER_DIR

echo "===== Downloading DocumentDB PEM file ====="
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -P $EVENT_SCHEDULER_DIR

echo "===== Giving ownership of $EVENT_SCHEDULER_DIR directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $EVENT_SCHEDULER_DIR

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Install pm2 log-rotate and save auto start configuration ====="
sudo -u appsvc bash <<EOF
pm2 install pm2-logrotate
pm2 save
EOF

echo "===== Run event-scheduler and save configuration ====="
sudo -u appsvc bash <<EOF
cd $EVENT_SCHEDULER_DIR
pm2 start dist/main.js --name event-scheduler
pm2 save
EOF

echo "===== Deleting $EVENT_SCHEDULER_TMP_DIR directory ====="
rm -rf $EVENT_SCHEDULER_TMP_DIR



echo "\n\n\n===== Finalizing setup ====="
echo "===== Giving ownership of env directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $ENV_DIR

echo "===== Configure pm2 to run on server startup using $SVC_USER ====="
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $SVC_USER --hp $APP_DIR


echo "SETUP COMPLETE!"
