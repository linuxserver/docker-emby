[linuxserverurl]: https://linuxserver.io
[forumurl]: https://forum.linuxserver.io
[ircurl]: https://www.linuxserver.io/irc/
[podcasturl]: https://www.linuxserver.io/podcast/
[appurl]: https://emby.media/
[hub]: https://hub.docker.com/r/linuxserver/emby/

[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)][linuxserverurl]

The [LinuxServer.io][linuxserverurl] team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io][forumurl]
* [IRC][ircurl] on freenode at `#linuxserver.io`
* [Podcast][podcasturl] covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# linuxserver/emby
[![](https://images.microbadger.com/badges/version/linuxserver/emby.svg)](https://microbadger.com/images/linuxserver/emby "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/image/linuxserver/emby.svg)](https://microbadger.com/images/linuxserver/emby "Get your own image badge on microbadger.com")[![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/emby.svg)][hub][![Docker Stars](https://img.shields.io/docker/stars/linuxserver/emby.svg)][hub][![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Builders/x86-64/x86-64-emby)](https://ci.linuxserver.io/job/Docker-Builders/job/x86-64/job/x86-64-emby/)

[emby](https://https://emby.media//) organizes video, music, live TV, and photos from personal media libraries and streams them to smart TVs, streaming boxes and mobile devices. This container is packaged as a standalone emby Media Server.

[![emby](https://emby.media/community/uploads/inline/3/55626b855503c_logo800.png)][appurl]

## Usage

```
docker create \
--name=emby \
-p 8096:8096 \
-p 8920:8920 \
-e PUID=<UID> -e PGID=<GID> \
-e TZ=<timezone> \
-v </path/to/library>:/config \
-v <path/to/tvseries>:/data/tvshows \
-v </path/to/movies>:/data/movies \
-v </path for transcoding>:/transcode \
linuxserver/emby
```

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`

* `-p 8096` - Emby WebUI Port
* `-p 8920` - Emby WebUI Port SSL
* `-v /config` - emby home folder location location. *This can grow very large, 50gb+ is likely for a large collection.*
* `-v /data/xyz` - Media goes here. Add as many as needed e.g. `/data/movies`, `/data/tv`, etc.
* `-v /transcode` - Path for transcoding folder, *optional*.
* `-e PGID=` for for GroupID - see below for explanation
* `-e PUID=` for for UserID - see below for explanation
* `-e TZ` - for timezone information *eg Europe/London, etc*

It is based on Alpine with s6 overlay, for shell access whilst the container is running do `docker exec -it emby /bin/sh`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" <sup>TM</sup>.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application
Webui can be found at `<your-ip>:8096`

## Info

* Shell access whilst the container is running: `docker exec -it emby /bin/sh`
* To monitor the logs of the container in realtime: `docker logs -f emby`

* container version number 

`docker inspect -f '{{ index .Config.Labels "build_version" }}' emby`

* image version number

`docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/emby`

## Versions

+ **12.29.17:** First Public version
