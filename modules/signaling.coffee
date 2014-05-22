crypto = require "crypto"
WebSocketServer = require("ws").Server
logger = require "./logger"
###
    WebSocket stuff
###

roomList = []

class Room
    constructor: (@name, @ws) ->

# new Room 
# new SingleRoom
# connect to Room

exports.connect = (server) ->

    wss = new WebSocketServer( server: server )

    wss.broadcast = (data) ->
        for i of @clients
            @clients[i].send data
        return
    
    wss.on "connection", (ws) ->
        logger.info "new ws connection"
        ws.peer = null
        ws.on "message", (msg) ->
            logger.info 'ws received: ', msg

            wss.broadcast msg

            console.log "----"+msg

            try
                originalMsg = msg
                msg = JSON.parse msg
                
                console.log "----"

                if !msg.type
                    throw new Error("msg.type not defined")

                logger.info "msg", msg

                switch msg.type
                    when "new"
                        logger.info "ws: got new msg"
                        id = crypto.randomBytes(20).toString "hex"
                        roomList.push 
                            id: id
                            ws: ws
                        ws.send JSON.stringify( 
                            type: "id"
                            value: id
                        )
                    when "connect"
                        for room in roomList
                            if msg.id is room.id 
                                room.ws.peer = ws
                        logger.info "ws: got connect msg"
                    when "offer"
                        if !ws.peer
                            ws.peer.send originalMsg
                        logger.info "ws: got offer msg"
                    when "answer"
                        if !ws.peer
                            ws.peer.send originalMsg
                        logger.info "ws: got answer msg"
                    when "candidate"
                        if !ws.peer
                            ws.peer.send originalMsg
                        logger.info "ws: got answer msg"
                    else 
                        console.log "asdfasfd"
                        logger.error "ws: unknown msg"
                
            catch e
                logger.error e
                #ws.close()

        ws.on "close", ->
            logger.info "ws connection closed"