winston = require "winston"
require "winston-logio"



log = new (winston.Logger)(transports: [
    new (winston.transports.Console)()
    new (winston.transports.File)(
        filename: "exceptions.log"
        name: "exceptions"
    )
    new (winston.transports.File)(
        filename: "errors.log"
        name: "errors"
    )
    new (winston.transports.File)(
        filename: "warnings.log"
        name: "warnings"
    )
    new (winston.transports.File)(
        filename: "infos.log"
        name: "infos"
    )
])

module.exports = log