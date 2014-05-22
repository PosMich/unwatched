# Unwatched


## Prerequisites

### Node.js

> #### NVM
>
> [Go there](https://github.com/creationix/nvm)
>
> #### Windows
>
> [Try this](http://www.ubuntu.com/download/desktop), [this](http://wiki.centos.org/Download), or [this](http://fedoraproject.org/get-fedora).
 
### coffee-script, grunt

```zsh
    npm install -g coffee-script
    npm install -g grunt-cli
```

### Pygments
needed to generate documentation

```zsh
    pip install Pygments
```

## Install

```zsh
    git clone xxxxx <name>
    cd <name>
    npm install
```

## Userconfig
A <b>*`userconfig.coffe`*</b> file must be created in the `modules` directory, because sensible data is stored here, it isn't checked in into the version control system.

```coffee
module.exports =
    port:
        http:   1234
        https:  1235
        livereload: 35729
    appName: "Unwatched"
    sessionSecret: ""
    ssl:
        key:    "cert/server.key"
        cert:   "cert/server.crt"
    log:
        dir: "logs/"
        level: "silly"
        files:
            exception: "exceptions.log"
            warning:   "warnings.log"
            error:     "errors.log"
            info:      "infos.log"
            silly:     "silly.log"
    logio:
        host:   "localhost"
        port:   28777
        node_name: "unwatched"
```

## Take a look at the Gruntfile!

```zsh
    grunt --help
```


## Docs
[groc](https://github.com/nevir/groc/) is used for generating the documentation.

The files are moved to the <b>*`public`*</b> dir, you can access them via **`http://servername/docs`**.

## Logs

[Install Log.io](http://logio.org/)

Edit `~/.log.io/harvester.conf`

example config:

```coffee
exports.config = {
    nodeName: "Unwatched Logfiles",
        logStreams: {
            exceptions: [ "/var/www/unwatched/logs/exceptions.log" ],
            errors: [ "/var/www/unwatched/logs/errors.log" ],
            warnings: [ "/var/www/unwatched/logs/warnings.log" ], 
            infos: [ "/var/www/unwatched/logs/infos.log" ],
            silly: [ "/var/www/unwatched/logs/silly.log" ]
        },
    server: {
        host: '0.0.0.0',
        port: 28777
    }
}
```


## TODO
*XSS!!!* node-validator


### CI
 Would be nice :)
