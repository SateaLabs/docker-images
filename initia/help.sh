# docker build -t --build-arg INITIA_VERSION=v0.2.14  sateanode/initia:v0.2.14 .
docker build -t  sateanode/initia:v0.2.14 .

docker run -d --name initia -e moniker=test2 -v ./data:/root/.initia satealabs/initia

docker run --rm -v ./data:/root/.initia satealabs/initia

echo -e "test1234\ntest1234" | initiad keys add test2

docker exec -ti initia curl -s localhost:27657/status | jq .result | jq .sync_info 

docker exec -ti initia initiad --node http://localhost:27657 query bank balances $(echo "test1234" | initiad keys show "$moniker" -a) --output json

docker exec -ti initia initiad debug addr $(echo "test1234" |initiad keys show "$moniker" -a)


echo "test1234" | initiad --node http://localhost:27657 tx mstaking create-validator \
    --amount=1000000uinit \
    --pubkey=$(initiad tendermint show-validator) \
    --moniker="$moniker" \
    --chain-id=$chainId \
    --commission-rate=0.05 \
    --commission-max-rate=0.2 \
    --commission-max-change-rate=0.1 \
    --from="$moniker" --gas 500000 --fees 300000uinit


balance=`echo "test1234" | initiad query bank balances $(initiad keys show "$moniker" -a) \
--node http://localhost:27657 \
--output json \
| jq '.balances[0].amount' \
| sed 's/^"\(.*\)"$/\1/' `
echo "balance: $balance"
num="1000000"
stakeBalance="$(expr $balance - $num)uinit"
echo "stake: $stakeBalance"
echo "test1234" | initiad --node http://localhost:27657 tx mstaking delegate "$(echo "test1234" | initiad keys show "$moniker" -a --bech val)" $stakeBalance \
    --from "$moniker" -y \
    --fees 200000uinit --gas 500000
