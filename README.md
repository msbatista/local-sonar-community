# About

This project is a sample of how to run sonar community with branch analysis plugin. Please refer to [mc1arke](https://github.com/mc1arke/sonarqube-community-branch-plugin).

## On linux hosts

Execute the following commands as [root](https://hub.docker.com/_/sonarqube):

```
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
```
