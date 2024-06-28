# Stack for build&run
Full docker stack for building and running a network of an XRootD server, an XRootD (caching) proxy, and a client. 

## Important Notes/ Q&As
**NOTE: The ToDos before starting are marked as checkboxes in this document** 
_____________
**NOTE2: The compilation ALWAYS happens in the proxy container for simplicity, as this is my main development target. (In the end, it does'n matter).**
_____________
**NOTE3: For security reasons, XRootD (server/proxy) cannot run as `root`! Therefore, you need to use `runuser` as done in the scripts!**
                                                                              
Example:  `runuser -u xrootd -- /build/src/xrootd -c /xrdconfigs/CONFIG -l /logs/mywhatever.log`
_____________
**NOTE4: The loglevels can be easily adapted in the `docker-compose.yml` by setting them as environment variables!**
_____________
**Q: How do I define that the client talks with the proxy without specifying it in the URL myself?**

A: This is done with XRootD's `XrdClProxyPlugin` and is defined in the `client-plugin-proxy.conf`!

**Q: What if I don't want to use the proxy?**

A: Just comment out the line `- ./configs/client-plugin-proxy.conf:/etc/xrootd/client.plugins.d/client-plugin-proxy.conf` in the `volumes` section of the `client` in the `docker-compose.yml`.
_____________
**Q: I get wierd `git` errors when running the self-compiled versions.**

A: Add `- ../.gitconfig:/root/.gitconfig` to the `volumes` section of each part.
This marks `/xrootd` as a safe directory.
_____________
**Q: I don't want full automatic transfers!**

A: Just increase the amount of `sleep` in the client `entrypoint` scripts (and my remove the xrd transfer). 
_____________
**Q: I don't want the cache to be wiped on every run!**

A: Comment out the `rm -r /cache/*` in the according `proxy_....sh` script.
_____________

## First Steps

### Define the Scenarios
First, it is important to adapt the docker stack to your desired scenario. 

The currently available default scenarios are listed below .
In general, you now should also consider which images and XRootD versions should be used. 
For that, you need to consider: What will I develop/test? Is it a client, a proxy, or a server feature? 
Or smth general? 
Should the server and the client use the same (compiled) version? 
Or should e.g. have the proxy a compiled version with changes but the client should be production-like?

**The default scenarios**: \
Overall, there are some things necessary before starting, depending on your scenario. Current scenarios are:
- (1) Full automatized scenario (internal): A server, a proxy, and a client are spawned. The client transfers a file from the server over the proxy.
  - [+] No need for proxy or ca-certs
  - [+] Ideal for initial testing, as network errors and all this stuff cannot happen
  - [-] No realistic scenario
  - ToDos: 
    - [ ] If you want a different testfile to be transferred, add it to `/store` and adapt the `client.sh` accordingly. 
    - [ ] It can happen that the compilation takes to long
- (2) Full automatized scenario (external): A server, a proxy, and a client are spawned. The client transfers a file from an in the `client_remote.sh` specified remote server over the proxy. I recommend CMS OpenData. The internal server is not used.
  - [+] No need for ca certificates and the proxy
  - [+] External connectivity is tested
  - [-] Still not realistic as cert/proxy errors are not testable, and you cannot test arbitrary (maybe faulty) remote servers
  - ToDos:
    -  [ ] Adapt the `client_remote.sh` (if desired)
- (3) Full automatized scenario (realistic): A server, a proxy, and a client are spawned. The client transfers a file from a in the `client.sh` specified remote server over the proxy. **Note, that a file must be put in `/store` and the `client.sh` entrypoint script must be adapted accordingly!.
  - [+] Realistic emulation of the grid components
  - [-] Most prerequisites, most complex, more error prone
  - ToDos:
    - [ ] `/cvmfs` must be available
    - [ ] A valid voms proxy is necessary in `/proxy`
    - [ ] Comment in the bind mounts for the ca certificates and the proxy in the `docker-compose.yml`, as well as the env variable `X509_USER_PROXY=/tmp/YOUR-PROXY`
    - [ ] adapt the `client_remote.sh` to your designated destination

### Adapt the Images
Accordingly, the images in the `docker-compose.yml` need to be adapted.
In general, it applies:
- I want production! -> use `image: rhofsaess/alma9_xrootd(_sha1)`
- I want my changes! -> use `image: rhofsaess/alma9_dev(_sha1)`

- On top of that, it is in principle also possible to use different compiled versions for the server, the client, and the proxy. 
But this is (not yet?) implemented.

#### Important
**When you want to use compiled versions, additionally the bind mounts must be commented-in in `docker-compose.yml`!**

### Adapt the `entrypoint` Scripts
And as well as the images, the **entrypoint scripts** need to be adapted when using the compiled version:
- Default XRootD: -> no change
- Compiled: `/build/src/xrootd` instead of `xrootd`, `/build/src/XrdCl/xrdcp` instead of `xrdcp`

### Adapt the Configs
As a final step, the **XRootD configs** in `/configs` need to be adapted to your use case!

### Authentication
**Overall, no authentication is implemented as it is not necessary for my current testing case. But it can easily be added!**

## Compilation
TODO: add details for compiling

## How to Run
`$ docker compose up [-d]`

If `-d` is used, you can check the logs with `$ docker compose logs`.
And all logs (server, proxy, client) are also available in `/logs`!



------------------
# ++++++++ FROM HERE: TODO ++++++++++
__________________

# Description of the Parts

### Server:

**Note: If the internal server is used, no certificates and no proxy is necessary** \
If the setup should replicate a usual grid access, those should be added and the corresponding volumes in the `docker-compose.yml` must be commented in! 

### Proxy
- [ ] Add grid ca certificates from grid-security/certificates to `ca-certificates` if necessary
- [ ] Add a valid grid proxy to `proxy` folder, if necessary.

**Note: The default setup uses an internal server or CMS OpenData. Therefore, no certs and no proxy are necessary.**


### Client
Two client scripts are available:
- `client_remote.sh`: Pulling several files from CMS opendata
- `client.sh`: Script that pulls from the local server running with the stack



- [ ] The client scripts are created to work without a grid proxy and CA certs. You may want to add them.
- [ ] You may need to adapt the sleep time if the compilation taks longer!









# My Old Documentation [**DEPRECATED**]
### Ubuntu 22.04 docker setup for XCache                                                            
Setup with development container for xrootd to test changes for the proxy.                             
It is a minimal setup with logging to file, but without a redirector, no monitoring.                   
NOTE: the images from `ubuntu_testing` must be build and available for using this stack!            
                                                                                                    
The full stack runs:                                                                                
  - the server, serving the files in ./store [using the minimal-server image]                       
  - the proxy, configured with the configs given in ./configs [using the compile image]             
  - the client, using the XrdClProxyPlugin                                                          
                                                                                                    
**NOTE: The X509 proxies need to be renewed, if you want to use external data sources with auth!**  
                                                                                                    
                                                                                                    
----- general -----                                                                                 
1) setup folders:                                                                                   
  `$ mkdir cache`                                                                                   
  `$ mdkir store`                                                                                   
  `$ mdkir certs`                                                                                   
  `$ mdkir build`                                                                                   
  optionally:                                                                                       
  `$ mkdir logs`                                                                                    
2) copy X509 proxy, if necessary:                                                                   
  `$ cp <proxy> ./certs>`                                                                           
  and adapt `docker-compose.yml`                                                                    
                                                                                                    
----- remarks -----                                                                                 
The setup currently uses the prebuild images from `ubuntu_testing` for the server and the client.   
                                                                                                    
For a new run, evtl clean the build dir before restarting.                                          
                                                                                                    
----- docker compose -----                                                                          
setup:                                                                                              
  `$ docker compose up -d`                                                                          
                                                                                                    
                                                                                                    
----- setup servers/ run testing -----                                                              
The provided setup automatically starts a server, compiles and runs the proxy, and start a client   
that pulls data from the server over the proxy.                                                     
                                                                                                    
1) server:                                                                                          
  - started automatically with docker compose                                                       
  - on startup, the ./scripts/server.sh script runs                                                 
  - logging to /logs/server.log                                                                     
  **NOTE: The export directory (/store) can be owned by root**                                      
                                                                                                    
2) proxy:                                                                                           
  - started automatically with docker compose                                                       
  - there are two ways to run this container:                                                       
    1) selecting ./scripts/build_and_run.sh as an entrypoint in the docer-compose-yml builds xrootd·
       from ../xrootd into ./build which is mounted as a bind mount                                 
    2) selecting ./scripts/proxy_compiled.sh starts the proxy without building                      
  - logging to /logs/proxy.log                                                                      
  **NOTE: The /cache directory must be owned by xrootd for writing!**
3) client:                                                                                          
  - Auto mode: ./scripts/client.sh as entrypoint performs a data transfer automatically on startup  
  - Manual mode: connect as a client and use XRootD                                                 
    `$ docker exec -it client-minimal-1 bash`                                                       
    **NOTE: For versions < 5.6 and > 5.3.1, it is necessary to use "XRD_CPUSEPGWRTRD=0" to avoid a bug in xrootd!**
    e.g.: `$ XRD_CPUSEPGWRTRD=0 xrdcp -d 2 -f root://10.5.0.6:1094//root://10.5.0.5:1094//storage/<file> .`
  - logging to /logs/client.log                                                                     
                                                                                                    
                                                                                                    
----- plain docker [outdated] -----                                                                 
building image:                                                                                     
  `$ docker build --rm -t ubuntu_compiled .`                                                        
                                                                                                    
run (no compose):                                                                                   
  `$ docker run -it -v /home/rhofsaess/working_dir/computing/xrootd_docker/xrootd:/xrootd -v ./configs:/xrdconfigs -v ./build:/build -v /cvmfs/grid.cern.ch/etc/grid-security/certificates:/etc/grid-security/certi
  Eventually, more folders need to be mounted (certs etc)                                           
                                                                                                    
building xrootd:                                                                                    
  run `scripts/build_xrd.sh`                                                                        
                                                                                                    
  `$ cd /build`                                                                                     
  run cmake:                                                                                        
  `$ cmake -DCMAKE_INSTALL_PREFIX=. ../xrootd                                                       
                                                                                                    
  - support VOMS: -DENABLE_VOMS=True                                                                
  - support HTTP TPC: -DENABLE_VOMS=True -DBUILD_MACAROONS=1                                        
  - support XrdClHTTP: -DXRDCLHTTP_SUBMODULE=1                                                      
  - support Erasure Coding: -DENABLE_XRDEC=True                                                     
  - support ASAN (CentOS 8 only): -DENABLE_ASAN=True                                                
                                                                                                    
  run make:                                                                                         
  `$ make -j 8`                                                                                     
  add user xrootd:                                                                                  
  `$ echo "xrootd:x:9997:9997::/home/xrootd:/bin/bash" >> /etc/passwd`                              
                                                                                                    
  To run the server:                                                                                
  `runuser -u xrootd -- /build/src/xrootd -c /xrdconfigs/CONFIG`
  
--------------------

# TODOs
- [ ] check, if /tmp/proxy works
- [ ] better proxy conf with explanations