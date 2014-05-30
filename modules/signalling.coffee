crypto = require "crypto"
WebSocketServer = require("ws").Server
logger = require "./logger"
###
    WebSocket stuff
###


exports.connect = (server) ->
    wss = new WebSocketServer( server: server )

    logger.info "wss init"
    wss.on "connection", (wsConnection) ->
        exists = true
        while exists
            exists = false
            id = crypto.randomBytes(20).toString "hex"
            for client in wss.clients
                if client.clientId? is id
                    exists true

        wsConnection.clientId = id
        wsConnection.isMaster = false


        logger.info "new ws connection"

        wsConnection.on "message", (msg) ->
            logger.info "got msg from"
            logger.info msg

            try
                parsedMsg = JSON.parse msg
                if !parsedMsg.type
                    throw new Error("msg.type not defined!")

                switch parsedMsg.type
                    # master --> server
                    when "new"
                        logger.info "ws: got 'new' msg"
                        wsConnection.isMaster = true

                        wsConnection.send JSON.stringify(
                            type: "id"
                            roomId: wsConnection.clientId
                        )

                    # client --> server --> master
                    when "connect"
                        logger.info "ws: got 'connect' msg from: " +
                            wsConnection.clientId
                        for client in wss.clients
                            if client.isMaster and client.clientId is parsedMsg.roomId
                                console.log "master found"
                                wsConnection.roomId = parsedMsg.roomId

                                client.send JSON.stringify(
                                    type: "connect"
                                    clientId: wsConnection.clientId
                                )
                                break

                        wsConnection.send JSON.stringify(
                            type: "id"
                            clientId: wsConnection.clientId
                        )

                    # master --> client
                    when "offer"
                        logger.info "ws: got 'offer' msg"
                        for client in wss.clients
                            if client.clientId is parsedMsg.clientId
                                client.send JSON.stringify(parsedMsg)
                                logger.info "offer sent to client"
                                break

                    # client --> master
                    when "answer"
                        logger.info "ws: got 'answer' msg"
                        for master in wss.clients
                            if master.clientId is wsConnection.roomId
                                master.send msg
                                logger.info "answer sent to master"
                                break

                    # send to other host
                    when "candidate"
                        logger.info "ws: got 'candidate' msg"
                        if wsConnection.isMaster
                            for client in wss.clients
                                if client.clientId is parsedMsg.clientId
                                    client.send msg
                        else
                            for client in wss.clients
                                if client.clientId is wsConnection.roomId
                                    client.send msg
                    else
                        logger.warn "type?"
            catch error
                logger.error error.message

        wsConnection.on "close", ->
            logger.info "ws connection closed"