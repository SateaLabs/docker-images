# docker-images

## dev command
docker build --no-cache -t  sateanode/ubuntu-pm2-0g-validator:latest .
docker logs -f 0g-validator
docker exec -ti 0g-validator bash
docker rmi sateanode/ubuntu-pm2-0g-validator
docker stop  0g-validator && docker rm  0g-validator
docker start  0g-validator
docker run -tid --name 0g-validator sateanode/ubuntu-pm2-0g-validator:latest
docker run --rm --name 0g-validator sateanode/ubuntu-pm2-0g-validator:latest cat .0gchain/config/config.toml
docker run --rm --name 0g-validator sateanode/ubuntu-pm2-0g-validator:latest cat shell.sh