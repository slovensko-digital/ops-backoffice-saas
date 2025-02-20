NAMESERVER=$(grep "nameserver" < /etc/resolv.conf | awk '{print $2}')
echo "resolver $NAMESERVER valid=5s;" > /etc/nginx/conf.d/resolver.conf

# Setup upstream rails and webdocket servers in nginx default conf
sed -e "s#<SERVICE_NAME>#${SERVICE_NAME}#g" -i /etc/nginx/sites-enabled/default

echo "starting nginx..."
exec /usr/sbin/nginx -g 'daemon off;'
