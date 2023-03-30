# autorun
Script to create and delete systemd services

## Installation
1. Download `.deb` file from releases
```
wget https://github.com/nikishefu/autorun/releases/download/v0.2.1/autorun_0.2.1_amd64.deb
```

2. Install via `dpkg`
```
dpkg -i autorun_0.2.1_amd64.deb
```

## Usage
```
[sudo] autorun [options] "executable"
```
#### Options:
```
        --help          Display this information
        --list          Display services
        --info name     Print name.service info
        --status name   Print name.service status
        -u username     Run service as username
        -n name         Name of service (required)
        -d              Delete service
        -s              Start service after creation
```
#### Note
- this script requires superuser privilege
- if `executable` contains spaces, surround this parameter by `"`

#### Example
```
sudo autorun -s -n mypythonserver "python3 -m http.server 9000"
```
This will create a new service running http server, that will launch immediately.
