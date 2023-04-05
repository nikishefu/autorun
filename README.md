# autorun
autorun is a script to manage systemd services. It provides a simple command-line interface to view, start, stop, delete and create systemd services.

## Installation
1. Download `.deb` file from releases
```
wget https://github.com/nikishefu/autorun/releases/download/v0.5.1/autorun_0.5.1_amd64.deb
```

2. Install via `dpkg`
```
dpkg -i autorun_0.5.1_amd64.deb
```

## Usage
```
[sudo] autorun [options] "executable"
```
#### Options:
```
        --help          Display this information
        -v              Display version information
        -l              Display all system services
        -L              Display services created with autorun
        -i              Print name.service info
        -s              Print name.service status
        -u username     Run service as username
        -n name         Name of service
        -d              Delete service
        -r              Run service
```
#### Note
- Some operations require superuser privilege
- Executable can be either a file or a command
- if `executable` contains spaces, surround this parameter by `"`

#### Example
```
sudo autorun -r -n mypythonserver "python3 -m http.server 9000"
```
This will create a new service running http server, that will launch immediately.

If you forgot -r option in service creation command, you can run your service with another command:
```
sudo autorun -n mypythonserver "python3 -m http.server 9000"
sudo autorun -r -n mypythonserver
```

## Screenshots
`autorun -l` marks services depending on their status:

![image](https://user-images.githubusercontent.com/37550111/230026224-cff31ef8-1d65-4a47-ac6a-cb6e7ad41406.png)
