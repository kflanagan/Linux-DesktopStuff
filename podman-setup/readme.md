# Setting up containers at home using Podman instead of docker




## Shell Scripts

Find a shell script for each container, these will do the following

- Create a user for the container
- Make sure that the user's home directory is created, and owned by the user
- Start the container
- Optionally
  - Create a base directory for data that will be used by volumes and make sure that the user created owns that
  

## Auto start of containers on boot

Podman does not behave the same way that Docker does in this regard.  Container startup is managed like any other installed software on a modern Linux system, with service files and systemctl.



To generate .service files for each container you 
``` sudo podman generate systemd --new  --files --name _container_name_ ```

Those service file should be copied to /usr/lib/systemd/system, then enable and start them with systemctl as any other daemon.

## Example

shell script
[firefox shell](./firefox-podman)

.service file
[firefox service](./container-firefox.service)


## Reference
[Redhat containers documentation](https://www.redhat.com/en/blog/container-systemd-persist-reboot)