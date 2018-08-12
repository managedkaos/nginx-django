# Update the package references
apt-get update

# Install nginx and supporting packages
apt-get install -y nginx

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
curl -s https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
python /tmp/get-pip.py
pip install virtualenv virtualenvwrapper
echo "export WORKON_HOME=~/Env" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
export WORKON_HOME=~/Env
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv django
pip install django
cd /mnt && django-admin.py startproject website
cd /mnt/website && sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['*'\]/g" ./website/settings.py
cd /mnt/website && echo 'STATIC_ROOT = os.path.join(BASE_DIR, "static/")' >> ./website/settings.py
cd /mnt/website && ./manage.py migrate
cd /mnt/website && ./manage.py collectstatic
cd /mnt/website && ./manage.py runserver 0.0.0.0:8080 &
