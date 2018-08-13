# Update the package references
apt-get update

# Install nginx and supporting packages
apt-get install -y nginx uwsgi uwsgi-plugin-python python-pip python-dev build-essential

# Remove the default configuration
unlink /etc/nginx/sites-enabled/default

# Install the new configuration
cp /vagrant/django.conf /etc/nginx/conf.d

# Create an SSL key and certificate
openssl req -batch -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt 2>/dev/null

# Load the configuration
systemctl reload nginx

# Setup and run Django
pip install virtualenv virtualenvwrapper
echo "export WORKON_HOME=/mnt/website/env" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
export WORKON_HOME=/mnt/website/env
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv django
pip install django
cd /mnt && django-admin.py startproject website
cd /mnt/website && sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['*'\]/g" ./website/settings.py
cd /mnt/website && echo 'STATIC_ROOT = os.path.join(BASE_DIR, "static/")' >> ./website/settings.py
cd /mnt/website && ./manage.py migrate
cd /mnt/website && ./manage.py collectstatic
#cd /mnt/website && ./manage.py runserver 0.0.0.0:8080 &

# Setup and run UWSGI
#mkdir /var/run/uwsgi
#chown www-data:www-data /var/run/uwsgi
cp /vagrant/uwsgi.conf /etc/init
cp /vagrant/uwsgi.service /etc/systemd/system/
cp /vagrant/django.uwsgi.ini /etc/uwsgi/apps-enabled
systemctl restart uwsgi
