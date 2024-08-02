FROM debian:bookworm-slim@sha256:16112ae93b810eb1ec6d1db6e01835d2444c8ca99aa678e03dd104ea3ec68408

RUN apt update -qq && apt upgrade --no-install-recommends -yqq \
  && apt install --no-install-recommends -yqq procps python3-pip uwsgi uwsgi-plugin-python3 python3-setuptools nginx runit \ 
  && mkdir /etc/service/nginx \
  && mkdir /etc/service/wsgi

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx.runit /etc/service/nginx/run
COPY wsgi.runit /etc/service/wsgi/run

WORKDIR /pinserver
COPY runit_boot.sh wsgi.ini requirements.txt wsgi.py server.py lib.py pindb.py __init__.py generateserverkey.py flaskserver.py /pinserver/
RUN pip3 install --upgrade pip wheel --break-system-packages
RUN pip3 install --require-hashes -r /pinserver/requirements.txt --break-system-packages
CMD ["/bin/bash", "-c", "chown www-data:www-data /pins; ./runit_boot.sh"]
