FROM sateanode/ubuntu-pm2:latest

ENV ORDER_ID="" \
    PRJECT_NAME="0g-validator" \
    MONIKER="My_Node" \
    WALLET_NAME="wallet"

RUN wget "https://raw.githubusercontent.com/SateaLabs/docker-images/main/0g-validator/shell.sh" \
    && chmod +x ./shell.sh \
    && ./shell.sh install --auto

ENV PATH=$PATH:/usr/local/go/bin:/root/go/bin

CMD ["./shell.sh","start"]

# docker build --no-cache -t  sateanode/ubuntu-pm2-0g-validator:latest .
# docker logs -f 0g-validator
# docker exec -ti 0g-validator bash
# docker stop  0g-validator && docker rm  0g-validator
# docker start  0g-validator
# docker run -tid --name 0g-validator sateanode/ubuntu-pm2-0g-validator:latest
# docker run --rm --name 0g-validator sateanode/ubuntu-pm2-0g-validator:latest cat .0gchain/config/config.toml
# docker run --rm --name 0g-validator sateanode/ubuntu-pm2-0g-validator:latest cat shell.sh