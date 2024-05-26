# Scripts
TODO



# copy_grid_proxy
This script, service, and timer are used to automatically copy a renewed voms proxy from the management node to the XRootD buffer node.\
To use this for automatization, a valid `VOMS proxy` on the management node and a functioning `SSH_AUTH_SOCK` are necessary, and the paths etc need to be adapted in the service file and the .sh script, as indicated in `copy_grid_proxy.sh`.


The unit file and the timer need to be placed at `/etc/systemd/system`. To enable the timer, do `$ systemctl enable copy-grid-proxy.timer`.

# copy_grid-security
This script is necessary for sites that do not provide CVMFS.
Its purpose is to regularly update the certificates in `/etc/grid-security`.
For this, it rsyncs the directory once a day from the management node that has CVMFS available to the XRootD node.\
To use this for automatization, a valid `VOMS proxy` on the management node and a functioning `SSH_AUTH_SOCK` are necessary, and the paths etc need to be adapted in the service file and the .sh script, as indicated in `copy_grid-security.sh`.\
Alternatively, cvmfsexec can be used to get the up-to-date certificates for the setup. However, since timers/cronjobs are typically not available on HPC for users, the automatization is difficult to impossible.


The unit file and the timer need to be placed at `/etc/systemd/system`. To enable the timer, do `$ systemctl enable copy-grid-security.timer`.
