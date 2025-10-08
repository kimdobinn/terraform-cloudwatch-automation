echo "===== Installing necessary COTS ====="

echo "===== Installing GIT ====="
yum install -y git

echo "===== Installing Java ====="
yum install -y java

echo "===== Installing Docker ====="
yum install -y docker

echo "===== Installing Docker-Compose ====="
curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo "===== Installing NodeJS / NPM ====="
curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
yum install -y nodejs

echo "===== Installing Python ====="
yum install -y python3

echo "===== Installing pip3 ====="
yum install -y python3-pip

echo "===== Installing gunicorn ====="
pip3 install gunicorn

echo "===== Installing PM2 ====="
npm install pm2@latest -g



echo -e "\n\n\n===== Installing build tools for building node-gyp ====="
echo "===== Installing GCC / GCC+ ====="
yum install -y gcc gcc-c++

echo -e "\n\n\n===== Installing build tools for building python modules ====="
echo "===== Installing python3-devel ====="
yum install -y python3-devel

echo -e "\n\n\n===== Installing postgres to initialize database ====="
export POSTGRESQL_NAME=postgresql15
yum install -y $POSTGRESQL_NAME

echo -e "\n\n\n===== Installing docker/docker-compose for building ai service ====="
yum install -y docker
docker --version
systemctl start docker.service

curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose


echo -e "\n\n\n===== Setting up base system ====="
# Declare service username variable
export SVC_USER=appsvc

echo "===== Creating service user $SVC_USER ====="
adduser $SVC_USER

# Declare application directory variables
export APP_DIR=/home/$SVC_USER



echo -e "\n\n\n===== Setting up ec2-user ssh authorization key ====="
echo '${authorization_key}' >> /home/ec2-user/.ssh/authorized_keys



echo -e "\n\n\n===== Setting up backend-api ====="
# Setup env variables and directories
export ENV_DIR=$APP_DIR/env
export BACKEND_ENV_DIR=$ENV_DIR/respiree-backend

echo "===== Creating env directory ====="
mkdir -p $BACKEND_ENV_DIR

echo "===== Creating backend-api env file ====="
echo '${backend_api_env}' > $BACKEND_ENV_DIR/.env

# Export backend-api application variables / directories
export BACKEND_API_FILE_NAME=backend-api.zip
export BACKEND_API_DIR=$APP_DIR/backend-api
export BACKEND_API_TMP_DIR=$BACKEND_API_DIR-tmp
export DOWNLOADED_BACKEND_API_FILE_PATH=$BACKEND_API_TMP_DIR/$BACKEND_API_FILE_NAME

echo "===== Creating backend-api directories ====="
mkdir -p $BACKEND_API_DIR
mkdir -p $BACKEND_API_TMP_DIR

echo "===== Downloading backend-api application from S3 ====="
aws s3 cp s3://respiree-artifact-bucket/${artifact_folder}/$BACKEND_API_FILE_NAME $BACKEND_API_TMP_DIR/
export BACKEND_API_EXTRACTED_DIR=$BACKEND_API_TMP_DIR/$(unzip -l $DOWNLOADED_BACKEND_API_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_BACKEND_API_FILE_PATH -d $BACKEND_API_TMP_DIR

echo "===== Changing directory to $BACKEND_API_EXTRACTED_DIR to build application ====="
cd $BACKEND_API_EXTRACTED_DIR

echo "===== Installing backend-api dependencies ====="
npm install --legacy-peer-deps
npm run build

echo "===== Moving built files from tmp directory to actual directory ====="
mv node_modules $BACKEND_API_DIR
mv assets $BACKEND_API_DIR
mv dist $BACKEND_API_DIR

echo "===== Giving ownership of $BACKEND_API_DIR directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $BACKEND_API_DIR

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Install pm2 log-rotate and save auto start configuration ====="
sudo -u appsvc bash <<EOF
pm2 install pm2-logrotate
pm2 save
EOF

echo "===== Run backend-api and save configuration ====="
sudo -u appsvc bash <<EOF
cd $BACKEND_API_DIR
pm2 start dist/src/main.js --name backend-api
pm2 save
EOF

echo "===== Deleting $BACKEND_API_TMP_DIR directory ====="
rm -rf $BACKEND_API_TMP_DIR




echo -e "\n\n\n===== Setting up mqtt-service ====="
# Export mqtt-service application variables / directories
export MQTT_SERVICE_FILE_NAME=mqtt-service.zip
export MQTT_SERVICE_DIR=$APP_DIR/mqtt-service
export MQTT_SERVICE_TMP_DIR=$MQTT_SERVICE_DIR-tmp
export DOWNLOADED_MQTT_SERVICE_FILE_PATH=$MQTT_SERVICE_TMP_DIR/$MQTT_SERVICE_FILE_NAME

echo "===== Creating mqtt-service-tmp directory ====="
mkdir -p $MQTT_SERVICE_TMP_DIR

echo "===== Downloading mqtt-service application from S3 ====="
aws s3 cp s3://respiree-artifact-bucket/$MQTT_SERVICE_FILE_NAME $MQTT_SERVICE_TMP_DIR/
export MQTT_SERVICE_EXTRACTED_DIR=$MQTT_SERVICE_TMP_DIR/$(unzip -l $DOWNLOADED_MQTT_SERVICE_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_MQTT_SERVICE_FILE_PATH -d $MQTT_SERVICE_TMP_DIR
mv $MQTT_SERVICE_EXTRACTED_DIR $MQTT_SERVICE_DIR

echo '${mqtt_service_env}' > $MQTT_SERVICE_DIR/.env

echo "===== Changing directory to $MQTT_SERVICE_DIR to install dependencies ====="
cd $MQTT_SERVICE_DIR
pip3 install -r requirements.txt

echo "===== Giving ownership of $MQTT_SERVICE_DIR directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $MQTT_SERVICE_DIR


echo "===== Run mqtt-service and save configuration ====="
sudo -u appsvc bash <<EOF
pwd
pip3 install -r requirements.txt
pm2 start "gunicorn -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:${mqtt_service_port} app.main:app" --name mqtt-service
pm2 save
EOF

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Deleting $MQTT_SERVICE_TMP_DIR directory ====="
rm -rf $MQTT_SERVICE_TMP_DIR



echo -e "\n\n\n===== Setting up stomp-service ====="
# Export stomp-service application variables / directories
export STOMP_SERVICE_FILE_NAME=stomp-service.zip
export STOMP_SERVICE_DIR=$APP_DIR/stomp-service
export STOMP_SERVICE_TMP_DIR=$STOMP_SERVICE_DIR-tmp
export DOWNLOADED_STOMP_SERVICE_FILE_PATH=$STOMP_SERVICE_TMP_DIR/$STOMP_SERVICE_FILE_NAME

echo "===== Creating stomp-service-tmp directory ====="
mkdir -p $STOMP_SERVICE_TMP_DIR

echo "===== Downloading stomp-service application from S3 ====="
aws s3 cp s3://respiree-artifact-bucket/$STOMP_SERVICE_FILE_NAME $STOMP_SERVICE_TMP_DIR/
export STOMP_SERVICE_EXTRACTED_DIR=$STOMP_SERVICE_TMP_DIR/$(unzip -l $DOWNLOADED_STOMP_SERVICE_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_STOMP_SERVICE_FILE_PATH -d $STOMP_SERVICE_TMP_DIR
mv $STOMP_SERVICE_EXTRACTED_DIR $STOMP_SERVICE_DIR

echo '${stomp_service_env}' > $STOMP_SERVICE_DIR/.env

echo "===== Changing directory to $STOMP_SERVICE_DIR to install dependencies ====="
cd $STOMP_SERVICE_DIR
pip3 install -r requirements.txt

echo "===== Giving ownership of $STOMP_SERVICE_DIR directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $STOMP_SERVICE_DIR


echo "===== Run stomp-service and save configuration ====="
sudo -u appsvc bash <<EOF
pwd
pip3 install -r requirements.txt
pm2 start "gunicorn -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:${stomp_service_port} app.main:app" --name stomp-service
pm2 save
EOF

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Deleting $STOMP_SERVICE_TMP_DIR directory ====="
rm -rf $STOMP_SERVICE_TMP_DIR



echo -e "\n\n\n===== Finalizing setup ====="
echo "===== Giving ownership of env directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $ENV_DIR

echo "===== Configure pm2 to run on server startup using $SVC_USER ====="
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $SVC_USER --hp $APP_DIR



echo -e "\n\n\n===== Deploy frontend dashboard ====="
# Export dashboard application directory
export DASHBOARD_FILE_NAME=dashboard.zip
export DASHBOARD_TMP_DIR=$APP_DIR/dashboard-tmp
export DOWNLOADED_DASHBOARD_FILE_PATH=$DASHBOARD_TMP_DIR/$DASHBOARD_FILE_NAME

echo "===== Creating dashboard directory ====="
mkdir -p $DASHBOARD_TMP_DIR

echo "===== Downloading dashboard application from S3 ====="
aws s3 cp s3://respiree-artifact-bucket/${artifact_folder}/$DASHBOARD_FILE_NAME $DASHBOARD_TMP_DIR/
export DASHBOARD_EXTRACTED_DIR=$DASHBOARD_TMP_DIR/$(unzip -l $DOWNLOADED_DASHBOARD_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_DASHBOARD_FILE_PATH -d $DASHBOARD_TMP_DIR

echo "===== Changing directory to $DASHBOARD_EXTRACTED_DIR to build application ====="
cd $DASHBOARD_EXTRACTED_DIR

echo "===== Creating dashboard env file ====="
echo '${dashboard_env}' >> .env

echo "===== Installing dashboard dependencies ====="
rm -rf node_modules package-lock.json
npm cache clean --force
npm install 
npm install --legacy-peer-deps
npm install linkify-html linkifyjs --save
npm install --save-dev @rollup/plugin-node-resolve

echo "===== Building dashboard ====="
npm run build

echo "===== Upload dashboard to frontend S3 bucket ====="
aws s3 cp build s3://${frontend_bucket_name} --recursive

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Deleting $DASHBOARD_TMP_DIR directory ====="
#rm -rf $DASHBOARD_TMP_DIR

echo "===== Copy static files from Artifact S3 bucket to app S3 bucket ====="
aws s3 cp s3://respiree-artifact-bucket/static_files/ s3://${app_bucket_name}/static_files/ --recursive

echo -e "\n\n\n===== Initializing database ====="
export DB_INIT_FILE_NAME=${s3_db_init_script_file_name}

echo "===== Downloading $DB_INIT_FILE_NAME from S3 ====="
aws s3 cp s3://respiree-configuration-bucket/${s3_db_init_script_key} /tmp/

export PGHOST="${db_host}"
export PGPORT="${db_port}"
export PGUSER="${db_username}"
export PGPASSWORD="${db_password}"
export PGDATABASE="${db_name}"

echo "===== Executing DB init script ====="
psql -f /tmp/$DB_INIT_FILE_NAME

echo "===== Cleaning up DB initialization ====="
rm /tmp/$DB_INIT_FILE_NAME

echo "===== Removing postgres ====="
yum remove -y $POSTGRESQL_NAME

echo "SETUP COMPLETE!"
