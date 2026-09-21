docker exec -d f7456ed24788 sh -c 'pkill -f tunserver.py; cd /volumes && python3 tunserver.py > server.log 2>&1'
docker exec -d b8d639ab0976 sh -c 'pkill -f tunclient.py; cd /volumes && python3 tunclient.py > client.log 2>&1'
sleep 5
docker top f7456ed24788 -eo args | grep tun
docker top b8d639ab0976 -eo args | grep tun
