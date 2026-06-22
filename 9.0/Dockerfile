FROM docker.io/nginx:1.27.3-bookworm
MAINTAINER Camptocamp
RUN apt-get update && apt-get remove curl -y && apt-get install -y netcat-openbsd && apt-get clean && rm -rf /var/lib/apt/lists/*
ADD https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd
RUN mkdir -p /etc/confd/{conf.d,templates}
COPY conf.d /etc/confd/conf.d
COPY templates /etc/confd/templates
COPY docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["/var/cache/nginx"]

ENTRYPOINT ["/docker-entrypoint.sh"]

ENV NGX_ODOO_HOST=odoo
ENV NGX_ODOO_PORT=8069
ENV NGX_ODOO_WAIT_TIMEOUT=300
ENV NGX_ODOO_LONGPOLLING_PORT=8072
ENV NGX_CACHE_SIZE=10m
# When set to a non-empty value, enables the fs_x_sendfile location block
# for X-Accel-Redirect proxying to S3-backed attachments (fs_attachment_s3).
ENV NGX_FS_X_SENDFILE=

CMD ["nginx", "-g", "daemon off;"]
