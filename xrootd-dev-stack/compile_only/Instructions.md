# Compile only
This docker stack is compiling xrootd using an Alma9 container provided from `rhofsaess/alma9_dev`.
1) Run `setup.sh`
2) Compile with: `$ docker compose up`
3) If something should be done after compiling, it can be added in `../scripts/build.sh`
