#!/bin/bash

while ! mysqladmin ping -hmariadb --silent; do
    sleep 1
done

cd /home/frappe/frappe-bench/sites
if [ ! -d "site1.local" ]; then
	cd /home/frappe/frappe-bench
	bench new-site site1.local --mariadb-root-password 123 --force
	bench get-app --branch master erpnext 
	bench --site site1.local install-app erpnext
fi	
cd /home/frappe/frappe-bench
bench start
