[![Build on Docker Hub](https://img.shields.io/docker/cloud/automated/customelements/schlund-ddns.svg)](https://hub.docker.com/r/customelements/schlund-ddns/) [![Stars on Docker Hub](https://img.shields.io/docker/cloud/build/customelements/schlund-ddns.svg)](https://hub.docker.com/r/customelements/schlund-ddns/) [![Pulls on Docker Hub](https://img.shields.io/docker/pulls/customelements/schlund-ddns.svg)](https://hub.docker.com/r/customelements/schlund-ddns/)

# schlund-ddns

Dockerized version of [wosc/schlund-ddns](https://github.com/wosc/schlund-ddns/)

This image runs a python flask server to update DNS Records managed by [SchlundTech](http://www.schlundtech.com/) by using their official [XML-Gateway](http://www.schlundtech.com/services/xml-gateway/).

Many thanks to [wosc](https://github.com/wosc/) and [martinlowinski/php-dyndns](https://github.com/martinlowinski/php-dyndns) for providing their projects to the public.


## Setup

### Configuration

#### Credentials

To get access to the XML-Gateway you'll have to provide your credentials.
Simply create a configuration file in the root of your docker folder.

	# copy the dist file
	cp .schlund-ddns.dist .schlund-ddns

	# and set your credentials using your preferred editor
	[default]
	username = ACCOUNT_ID
	password = ACCOUNT_PASSWORD

#### docker-compose

A basic [docker-compose.yaml](./docker-compose.yaml) is prioveded in this project an may look like this

	version: '3'
	services:
	  schlundddns:
	    image: customelements/schlund-ddns
	    container_name: schlund-ddns
	    ports:
	      - "5000:5000"
	    volumes:
	      - ./.schlund-ddns:/schlund-ddns/.schlund-ddns
	    environment:
	      - DDNS_CONFIG=/schlund-ddns/.schlund-ddns

This will start the application mounting your credentials file with public access to port 5000

### Start the application

	docker-compose up -d

### Execute an DNS Record update by http

Now you should be able to update a DNS Record of a subdomain by calling the url like this:

	http://localhost:5000/?hostname=your.subdomain.tld&myip=0.0.0.0
	
**Pay Attention:** It is only possible to update a subdomain of an A-Record like: `sub.domain.tld`. 
It is not possible to update A-Records like `domain.tld` or `my.sub.sub.domain.tld`

### Execute an DNS Record update by CLI

When the container is up and running it is listening on port 5000.
You can also use the CLI `schlund-ddns` to update a DNS Record from the command line. If doing that, you'll have to provide the credentials as parameters. It is recommended to pass the credentials as environment variables in your docker-compose file to avoid sensible data in your command history.

	docker exec -it schlund-ddns schlund-ddns --username <USER> --password $PASS your.host.tld 0.0.0.0

## Setup with Traefik and basic auth

To use schlund-ddns behind a proxy like [Traefik](https://traefik.io), check out the [docker-compose.traefik.yaml](./docker-compose.traefik.yaml) file. You should have some basic knowledge of setting up traefik. For more information visit the offical docs at [docs.traefik.io](https://docs.traefik.io/)

### create basic auth credentials

First we will create our encrypted basic auth credentials

For security reason: Read your password into an environment variable called `PASS`

	read -p "Password:" -s PASS

use htpasswd to create your basic auth key, replace `<USER>` with a name of your choice

	echo $(htpasswd -nbB <USER> "$PASS") | sed -e s/\\$/\\$\\$/g

if you do not have htpasswd installed, install it with `sudo apt-get install apache2-utils` or use a docker image like

	docker run --rm -ti xmartlabs/htpasswd <USER> $PASS  | sed -e s/\\$/\\$\\$/g

Put the output into the `traefik.frontend.auth.basic` label

	- "traefik.frontend.auth.basic=<USER-PASSWORD-OUTPUT>"

### docker-compose

Here is an example [docker-compose.traefik.yaml](./docker-compose.traefik.yaml) configuration file

	version: '3'
	services:
	  schlundddns:
	    image: customelements/schlund-ddns
	    container_name: schlund-ddns
	    networks:
	      - traefik
	    volumes:
	      - ./.schlund-ddns:/schlund-ddns/.schlund-ddns
	    environment:
	      - DDNS_CONFIG=/schlund-ddns/.schlund-ddns
	    labels:
	      - "traefik.docker.network=traefik"
	      - "traefik.enable=true"
	      - "traefik.basic.frontend.rule=Host:YOUR.HOST.TLD"
	      - "traefik.port=5000"
	      - "traefik.protocol=http"
	      - "traefik.frontend.headers.SSLRedirect=false"
	      - "traefik.frontend.auth.basic=<USER-PASSWORD-OUTPUT>"
	
	networks:
	  traefik:
	    external: true


