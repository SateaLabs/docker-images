IP=`curl https://vims.satea.sekai.me/api/v1/utils/ip`
echo $IP
url="https://buzzard-discrete-mastiff.ngrok-free.app/initia/data?ip=$IP"
params=`curl --location -k $url \
--header 'Content-Type: application/json' \
--header 'ngrok-skip-browser-warning: 1'`
NODE_NAME=`echo $params | jq '.name' | sed 's/^"\(.*\)"$/\1/'`
echo $NODE_NAME

docker run -d --name initia -e moniker="$NODE_NAME" -v ./initia:/root/.initia sateanode/initia:v0.2.14

# docker run --rm -e moniker="$NODE_NAME" -v ./initia:/root/.initia sateanode/initia:v0.2.14
