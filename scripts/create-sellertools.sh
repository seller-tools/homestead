#!/usr/bin/env bash

stpath=$1

cat > /etc/systemd/system/st-app.target <<EOF
[Unit]
Description=Seller tools
After=network.target php7.1-fpm.service
Wants=st-frontend.service\
		st-backend.target 
EOF

cat > /etc/systemd/system/st-backend.target <<EOF
[Unit]
Description=Seller tools Backend
After=rabbitmq-server.target elasticsearch.service
Wants=st-fetchers.target \
		st-spiders.target \
		st-mwsworkers.target \
		st-echo.service
PartOf=st-app.target
EOF

cat > /etc/systemd/system/st-fetchers.target <<EOF
[Unit]
Description=Seller tools Fetchers
PartOf=st-backend.target
Wants=st-fetcher@fetcher-default.service \
		st-fetcher@fetcher-priority.service \
		st-fetcher@progress.service
EOF

cat > /etc/systemd/system/st-spiders.target <<EOF
[Unit]
Description=Seller tools Spiders
PartOf=st-backend.target
Wants=st-spider@default.service \
		st-spider@medium.service \
		st-spider@index.service \
		st-spider@priority.service
EOF

cat > /etc/systemd/system/st-mwsworkers.target <<EOF
[Unit]
Description=Seller tools Spiders
PartOf=st-backend.target
Wants=st-mwsworker@default.service \
		st-mwsworker@priority.service
EOF

cat > /etc/systemd/system/st-fetcher@.service <<EOF
[Unit]
Description=Seller tools Fetcher
After=network.target
PartOf=st-fetchers.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=$stpath
ExecStart=/usr/bin/php ${stpath}/fetcher/artisan worker:run %i
EOF

cat > /etc/systemd/system/st-spider@.service <<EOF
[Unit]
Description=Seller tools Spider
After=network.target
PartOf=st-spiders.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=$stpath
ExecStart=/usr/bin/php ${stpath}/spider/src/worker.php spider-%i
EOF

cat > /etc/systemd/system/st-mwsworker@.service <<EOF
[Unit]
Description=Seller tools Mws worker
After=network.target
PartOf=st-mwsworkers.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=$stpath
ExecStart=/usr/bin/php ${stpath}/mwsworker/src/worker.php mws-%i
EOF

cat > /etc/systemd/system/st-echo.service <<EOF
[Unit]
Description=Seller tools Echo server
After=network.target
PartOf=st-backend.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=${stpath}/echo-server
ExecStart=/usr/bin/laravel-echo-server start
EOF

cat > /etc/systemd/system/st-frontend.service <<EOF
[Unit]
Description=Seller tools Frontend
After=network.target
PartOf=st-app.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=${stpath}/frontend
ExecStart=/usr/bin/yarn start
EOF

echo "Configuring SellerTools"

for example_f in $(find $stpath | grep -v 'vendor\|node_modules' | grep '.example$'); do
	target_f=${example_f%.example}
	if [ ! -f $target_f ]; then
	    echo "Copying example file for $target_f"
	    cp $example_f $target_f
	fi
done

echo "Composer install"
if [ ! -f /home/vagrant/.ssh/known_hosts ]; then 
	ssh-keyscan github.com > /home/vagrant/.ssh/known_hosts
fi
sudo -u vagrant -H sh -c "cd ${stpath}; /usr/local/bin/composer install" 

echo "Yarn"
cd ${stpath}/frontend
yarn

cd ${stpath}/app
## Check migrations
if [[ $(/usr/bin/php artisan migrate:status) = 'No migrations found.' ]]; then
	echo "Migrating database"
	/usr/bin/php artisan migrate --seed
 
	echo "Generating app key"
	appkey=$(/usr/bin/php artisan key:generate --show)

	sed -i "/APP_KEY=/c\APP_KEY=$appkey" .env

	echo "Generating jwt secret"
	/usr/bin/php artisan jwt:secret -nf

	cd ${stpath}/fetcher
	sed -i "/APP_KEY=/c\APP_KEY=$appkey" .env

	echo "Request product sync"
	/usr/bin/php artisan amazon:product-sync --cred_id 1	

	cd ${stpath}/supervisor
	sed -i "/APP_KEY=/c\APP_KEY=$appkey" .env
fi

systemctl daemon-reload

exit 0