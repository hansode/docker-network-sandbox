# daemon flag -icc

via [DOCKER 0.6.5: NAME YOUR CONTAINERS, LINK THEM TOGETHER, SELECTIVELY PUBLISH PORTS, AND MORE](http://blog.docker.io/2013/10/docker-0-6-5-links-container-naming-advanced-port-redirects-host-integration/)

> Links: service discovery for docker
>
> Links allow containers to discover and securely communicate with each other. In 0.6.5 inter-container communication can be disabled with the daemon flag -icc=false. With this flag set to false, Container A cannot access Container B unless explicitly allowed via a link. This is a huge win for securing your containers. When two containers are linked together Docker creates a parent child relationship between the containers. The parent container will be able to access information via environment variables of the child such as name, exposed ports, ip, and environment variables.
>
> When linking two containers Docker will use the exposed ports of the container to create a secure tunnel for the parent to access. If a database container only exposes port 8080 then the linked container will only be allowed to access port 8080 and nothing else if inter-container communication is set to false.

## Compare iptables rules of -icc=true and -icc=false

+ node01: `-icc=true`
+ node02: `-icc=false`

### Usage

```
$ make node01 node02
$ diff -r shared.d/node0{1,2}
```
