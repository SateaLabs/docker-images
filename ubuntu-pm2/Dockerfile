FROM sateanode/ubuntu:latest

RUN apt-get update
RUN apt-get -y install \
    nodejs \
    npm
RUN npm install pm2 -g

# docker build -t sateanode/ubuntu-pm2:latest . 