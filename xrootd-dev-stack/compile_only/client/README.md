# Using the Compiled XRootD as a Client
1) Adapt the amount of `sleep` time in `/scripts/client_compiled.sh` to 1000 or inf.
2) `$ docker compose up -d` to start
2) `$ docker exec -it client_compiled bash` to connect
3) Do whatever you have to :D \
(To run XRootD, use `/build/src/xrootd`)
4) `$ docker compose down` to stop
 