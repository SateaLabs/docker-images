FROM sateanode/ubuntu-pm2:latest

ENV ORDER_ID="" \
    PRJECT_NAME="0g-validator" \
    MONIKER="My_Node" \
    WALLET_NAME="wallet"

RUN wget "https://raw.githubusercontent.com/SateaLabs/docker-images/main/0g-validator/shell.sh" \
    && chmod +x ./shell.sh \
    && ./shell.sh install --auto

ENV PATH=$PATH:/usr/local/go/bin:/root/go/bin

ENTRYPOINT ["bash","shell.sh","start"]