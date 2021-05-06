# Icecast Container

Serve your radio in container.

## Example Run

```bash
root@a789a794-sv/container/icecast>docker run -it --rm -e authentication_source_password=sourcepw -p 8000:8000 ghcr.io/ahmetozer/icecast
        Admin username is 'admin' and password is:   FGOt3cRGjrgLUc4F
        authentication_source_password password is specified by user:             so...pw
        authentication_relay_password password is:    qBBa5KFEKgDGJRfQ
        Selected port is 8000/tcp
        limits_clients 100
        limits_sources 2
        bind_address ::
```

## Configure

You can configure settings via setting enviroment variables

- admin  
Provides admin user name

- authentication_source_password  
Password for source

- authentication_relay_password  
Password for relay

- port  
Bind Icecast for different port in container. This makes sense if you use with IPv6 in containers and without ingress proxy.

- limits_clients  
Client limit for the server

- limits_sources  
source limit for the server

- bind_address
Icecast bind address

![image](https://github.com/ahmetozer/icecast-container/raw/docs/exampleStream.jpg)
