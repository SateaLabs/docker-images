FROM sateanode/ubuntu-pm2:latest

ENV ORDER_ID ""
ENV PRJECT_NAME "0g-validator"
ENV MONIKER "My_Node"
ENV WALLET_NAME "wallet"

# RUN wget "" \
#     && chmod +x ./shell.sh \
#     && ./shell.sh install

COPY ./shell.sh ./
RUN chmod +x ./shell.sh &&  ./shell.sh install --auto
ENV PATH $PATH:/usr/local/go/bin:$HOME/go/bin
# ENTRYPOINT ["sh","shell.sh","install","--auto"]

CMD ["./shell.sh","start"]