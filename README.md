# autorun
Script to manage systemd services

## Installation
1. Download `.deb` file from releases
```
wget https://github.com/nikishefu/autorun/releases/download/v0.3.0/autorun_0.3.0_amd64.deb
```

2. Install via `dpkg`
```
dpkg -i autorun_0.3.0_amd64.deb
```

## Usage
```
[sudo] autorun [options] "executable"
```
#### Options:
```
        --help          Display this information
        -v              Display version information
        -l              Display services
        -i              Print name.service info
        -s              Print name.service status
        -u username     Run service as username
        -n name         Name of service
        -d              Delete service
        -r              Run service after creation
```
#### Note
- Some operations require superuser privilege
- Executable can be either a file or a command
- if `executable` contains spaces, surround this parameter by `"`

#### Example
```
sudo autorun -s -n mypythonserver "python3 -m http.server 9000"
```
This will create a new service running http server, that will launch immediately.
