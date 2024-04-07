# Various things to remember for home Docker 

[This link will get you going with SSH keys and github for pushing updates](https://linuxkamarada.com/en/2019/07/14/using-git-with-ssh-keys/#.YhEAZ3XMLHU)


## If you get the error installing containers from Docker that it can't srart containers, see this page
[Ubuntu default DNS](https://www.mail-archive.com/ubuntu-bugs@lists.ubuntu.com/msg5968593.html)

## Dashy

 Suggested config, but until I can work out where the config file goes I removed the -v line

	docker run -d -p 8080:80 -v /home/dashy/my-conf.yml:/app/public/conf.yml --name my-dashboard --restart=always lissy93/dashy:latest

## AudioBookShelf
[Audiobookshelf home](https://www.audiobookshelf.org/)

 	docker run -d  --restart=always -p 13378:80   -v /media2/audiobookshelf/config:/config   -v /media2/audiobookshelf/metadata:/metadata   -v /media2/audiobookshelf/audiobooks:/audiobooks   -v /media2/audiobookshelf/podcasts:/podcasts   --name audiobookshelf ghcr.io/advplyr/audiobookshelf



## Jellyfin

	docker run -d  --name jellyfin --user uid:gid --net=host --volume /media/jellyfin/config:/config --volume /media/jellyfin/cache:/cache  --mount type=bind,source=/media/plex,target=/media --restart=unless-stopped  jellyfin/jellyfin



## Portainer is a docker container to manage docker
	sudo docker volume create portainer_data
	sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

### To update portainer
	sudo docker ps
	sudo docker stop portainer
	docker rm the container from the PS command
	sudo docker images
	sudo docker rmi -- The image number of the portainer image
	Do the docker run from above

## Pihole
[First you need to stop Ubuntu's DNS provider](https://www.linuxuprising.com/2020/07/ubuntu-how-to-free-up-port-53-used-by.html)

I set it to use 8.8.8.8 for DNS provider
[This video was really helpful](https://www.youtube.com/watch?v=dH3DdLy574M&t=160s&ab_channel=NetworkChuck)

There is a script just called "pihole" in this repo, it's functional, if you already have the container it will fail, so remove it first. This was the image I used, and there are good directions [here](https://hub.docker.com/r/pihole/pihole)
- create a directory, I used /home/pi-hole	
- See the shell script in this directory, pihole.  
- Copy it to that directory, run it from there.
- docker pull pihole/pihole


## Home Assistant, mostly documented elsewhere
### Fresh installation
- First you need to make /home/ha

		mkdir /home/ha
- Docker run line for my config, paths are specific

		docker run -d --name="home-assistant" --restart always -v /home/ha:/config -v /var/run/docker.sock:/var/run/docker.sock  -v  /etc/localtime:/etc/localtime:ro -v /media/music:/media --net=host homeassistant/home-assistant


### Upgrades

	sudo docker ps
    sudo docker stop home-assistant
	sudo docker rm home-assistant
    sudo docker images
    sudo docker rmi -- The image number of the Home-Assistant image
	Repeat the Docker run command above

## Create a mysql instance, set up for Home Assistant DB
I have not made this work yet, but still want to

	docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag

## Create a MySQL instance for the NC Voter Database 
	sudo mkdir /var/NCVoterDB
	sudo docker run -d -p 3306 --name NCVoterDB --restart always -v /var/NCVoterDB -v /etc/localtime:/etc/localtime:ro mysql/mysql



## To install plex in a docker container

- Create the directories

		mkdir -p ~/media/plex/{config,data}

- Then the docker run

		docker run -d   --name=plex   --net=host   -e PUID=1001   -e PGID=1001   -e TZ=Etc/UTC   -e VERSION=docker   -e PLEX_CLAIM= `#optional`   -v /media/plex/config:/config   -v /media/plex/music:/music   -v /media/plex/MusicVideos:/MusicVideos   --restart unless-stopped  lscr.io/linuxserver/plex:latest




## Create a MySQL instance for the NC Voter Database 
	sudo mkdir /var/NCVoterDB
	sudo docker run -d -p 3306 --name NCVoterDB --restart always -v /var/NCVoterDB -v /etc/localtime:/etc/localtime:ro mysql/mysql


## Grafana
[Dockerhub](https://hub.docker.com/r/grafana/grafana)

	docker pull grafana/grafana
	docker run -d --name=grafana --restart=unless-stopped -v /etc/localtime:/etc/localtime:ro  -v /home/ha:/hadata -p 3000:3000 grafana/grafana



## Node Red 
This confguration also has Home Assistant data mounted for the log files

	docker run -it -p 1880:1880 -v myNodeREDdata:/data/nodered --name mynodered nodered/node-red


## Apache
	docker run -dit --name my-apache-app -p 8080:80 -v "$PWD":/usr/local/apache2/htdocs/ httpd:2.4
