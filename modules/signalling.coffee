crypto = require "crypto"
WebSocketServer = require("ws").Server
logger = require "./logger"
###
    WebSocket stuff
###

###
roomList = []

class Room
    constructor: (@name, @ws) ->
###

###
class Rooms
    class Room
        @clients = [] 
        constructor: (@id, @masterId) ->
        add: (clientId) ->
            clients.push []

    constructor: (@roomList = []) ->
    newId: ->
        crypto.randomBytes(20).toString "hex"
    createId: ->
        id = null
        exist = true
        while exist
            exist = false
            id = @newId()
            for room in @roomList
                if room.id is id
                    exist = true
        return id

    add: (masterId) ->
        for room in @roomList
            return false if room.masterId is masterId 
        id = @createId()
        @roomList.push new Room(id, masterId)
        return true
    get: (roomId) ->
        for room in @roomList
            return room if room.id is roomId
        return 
    getMasterId: (roomId) ->
        for room in @roomList
            console.log "room: "
            console.log room
            return room.masterId if room.id is roomId
        return
    getRoomId: (masterId) ->
        for room in @roomList
            return room.id if room.masterId is masterId
###


exports.connect = (server) ->
    #rooms = new Rooms
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
        #console.log wsConnection

        wsConnection.on "message", (msg) ->
            logger.info "got msg from"
            logger.info msg
            #console.log wsConnection
            #console.log wsConnection.client
            try 
                parsedMsg = JSON.parse msg
                if !parsedMsg.type
                    throw new Error("msg.type not defined!")

                switch parsedMsg.type 
                    when "new" # master --> server
                        logger.info "ws: got 'new' msg"
                        wsConnection.isMaster = true

                        wsConnection.send JSON.stringify(
                            type: "id"
                            roomId: wsConnection.clientId
                        )

                        ###
                        if rooms.add(wsConnection.clientId)
                            logger.info "created new room"
                            # tell the master his roomId
                            wsConnection.send JSON.stringify( 
                                type: "id"
                                roomId: rooms.getRoomId(wsConnection.clientId)
                            )
                        else
                            logger.warn "this Client allready created a room"
                            wsConnection.send JSON.stringify(
                                type: "error"
                                message: "allready created a room"
                            )
                        ###

                    when "connect" # client --> server --> master
                        logger.info "ws: got 'connect' msg from: " + wsConnection.clientId
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
                        ###
                        masterId = rooms.getMasterId(parsedMsg.roomId)
                        console.log "master's id: "+masterId
                        
                        for master in wss.clients
                            console.log "clientId: "+master.clientId
                            if master.clientId is masterId
                                console.log "room found"
                                master.send JSON.stringify(
                                    type: "connect"
                                    clientId: wsConnection.clientId
                                )
                                wsConnection.masterId = master.clientId
                                wsConnection.send JSON.stringify( 
                                    type: "id"
                                    clientId: wsConnection.clientId
                                )
                                logger.info "sent connect msg"
                                break
                        ###
                    when "offer" # master --> client                                
                        logger.info "ws: got 'offer' msg"
                        for client in wss.clients
                            if client.clientId is parsedMsg.clientId
                                client.send JSON.stringify(parsedMsg)
                                logger.info "offer sent to client"
                                break
                                                          
                    when "answer" # client --> master     
                        logger.info "ws: got 'answer' msg"
                        for master in wss.clients
                            if master.clientId is wsConnection.roomId
                                master.send msg
                                logger.info "answer sent to master"
                                break

                    when "candidate" # send to other host
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
            #for room in roomList
            #    if room.ws is 
            logger.info "ws connection closed"