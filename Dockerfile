# Frappe Bench Dockerfile

FROM debian:9.6-slim
LABEL author=frappé

# Set locale C.UTF-8 for mariadb and general locale data
ENV LANG C.UTF-8

# Install all neccesary packages
RUN apt-get update && apt-get install -y --no-install-suggests --no-install-recommends build-essential mysql-client dos2unix cron curl git iputils-ping libffi-dev \
  liblcms2-dev libldap2-dev libmariadbclient-dev libsasl2-dev libssl-dev libtiff5-dev libwebp-dev mariadb-client \
  python-dev python-pip python-setuptools python-tk redis-tools rlwrap software-properties-common sudo tk8.6-dev \
  vim xfonts-75dpi xfonts-base wget wkhtmltopdf \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && pip install --upgrade setuptools pip --no-cache \
  && curl https://deb.nodesource.com/node_10.x/pool/main/n/nodejs/nodejs_10.10.0-1nodesource1_amd64.deb > node.deb \
  && dpkg -i node.deb \
  && rm node.deb \
  && npm install -g yarn

# Add frappe user and setup sudo
RUN useradd -ms /bin/bash -G sudo frappe \
  && printf '# Sudo rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/frappe

WORKDIR /home/frappe
# Install bench
RUN pip install -e git+https://github.com/frappe/bench.git#egg=bench --no-cache

USER frappe
# Add some bench files
#COPY --chown=frappe:frappe ./frappe-bench /home/frappe/frappe-bench
#WORKDIR /home/frappe/frappe-bench

EXPOSE 8000 9000 6787

#VOLUME [ "/home/frappe/frappe-bench" ]

USER root
#RUN chown -R frappe:frappe ./*

USER frappe
WORKDIR /home/frappe
RUN bench init frappe-bench --frappe-branch master --ignore-exist --skip-redis-config-generation
WORKDIR /home/frappe/frappe-bench
ADD common_site_config_docker.json /home/frappe/frappe-bench/sites/common_site_config.json

COPY entrypoint.sh /home/frappe
RUN sudo chmod 755 /home/frappe/entrypoint.sh
RUN sudo dos2unix /home/frappe/entrypoint.sh
ENTRYPOINT ["/home/frappe/entrypoint.sh"]

#RUN bench new-site site1.local --mariadb-root-password 123
#RUN bench get-app erpnext
#RUN bench --site site1.local install-app erpnext
