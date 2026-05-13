## 👋 Welcome to ollama 🚀  

ollama README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update ollama
```
  
## Install and run container
  
```shell
dockerHome="/var/lib/srv/$USER/docker/casjaysdevdocker/ollama/ollama/latest/rootfs"
mkdir -p "/var/lib/srv/$USER/docker/ollama/rootfs"
git clone "https://github.com/dockermgr/ollama" "$HOME/.local/share/CasjaysDev/dockermgr/ollama"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/ollama/rootfs/." "$dockerHome/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-ollama-latest \
--hostname ollama \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 80:80 \
casjaysdevdocker/ollama:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/ollama
    container_name: casjaysdevdocker-ollama
    environment:
      - TZ=America/New_York
      - HOSTNAME=ollama
    volumes:
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/ollama/ollama/latest/rootfs/data:/data:z"
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/ollama/ollama/latest/rootfs/config:/config:z"
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/ollama
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/ollama" "$HOME/Projects/github/casjaysdevdocker/ollama"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/ollama"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
