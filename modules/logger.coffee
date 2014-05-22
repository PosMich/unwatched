winston = require "winston"
require "winston-logio"

config = require "./userconfig"


logger = new (winston.Logger)(transports: [
    new (winston.transports.Console)(
        colorize: true
    )
    new (winston.transports.File)(
        filename: config.log.dir+config.log.files.error
        name: "errors"
        label: "errors"
        level: "error"
    )
    new (winston.transports.File)(
        filename: config.log.dir+config.log.files.warning
        name: "warnings"
        label: "warnings"
        level: "warn"
    )
    new (winston.transports.File)(
        filename: config.log.dir+config.log.files.info
        name: "infos"
        label: "infos"
        level: "info"
    )
    new (winston.transports.File)(
        filename: config.log.dir+config.log.files.silly
        name: "silly"
        label: "silly"
        level: "silly"
    )
    new (winston.transports.Logio)(
        port: config.logio.port
        node_name: config.logio.node_name
        host: config.logio.host
    )
])

logger.handleExceptions new (winston.transports.File)(
    filename: config.log.dir+config.log.files.exception
    name: "exceptions"
    label: "exceptions"
    handleExceptions: true
    json: true
)

logger.exitOnError = false

module.exports = logger