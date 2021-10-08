service postgresql start
service apache2 start

# fork a process and wait for it
tail -f /var/log/postgresql/postgresql-12-main.log &
wait
