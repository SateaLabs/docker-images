FROM sateanode/ubuntu:latest

RUN rm -rf /usr/local/go
RUN curl -L https://go.dev/dl/go1.22.2.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile