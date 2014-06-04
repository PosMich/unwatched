# Unwatched - PTP Factory
# ============================

"use strict"



class P2PService
    @::debug = true
    @::p2p
    @::p2pConnections = []

    class P2pRequestConnection
        @::type = "requester"
        @::debug = false
        @::userId
        @::resolverId
        @::itemId
        @::item
        @::connection
        @::dataChannel
        @::isMaster = false
        @::createDC = false
        @::CHUNK_SIZE = 1000
        @::chunkCounter = 0
        @::sdpConstraints =
            optional: []
            mandatory:
                OfferToReceiveAudio: true
                OfferToReceiveVideo: true

        constructor: (@service, @p2p, @itemId) ->
            console.log "p2pRequest: constructor" if @debug
            @item = @service.SharesService.get @itemId
            @resolverId = @item.author
            @userId = @service.$rootScope.userId
            @isMaster = @service.UserService.getUser(@userId).isMaster
            @FileService = @service.FileService

            if @item.category is "file" or @item.category is "image"
                @createDC = true
                @sdpConstraints = null
            else if @item.category is "screen"
                @sdpConstraints.mandatory.OfferToReceiveAudio = false

            try
                @connection = new RTCPeerConnection
                    iceServers:  @p2p.iceServers
                ,
                    null
            catch error
                console.log "AAAAAH"
                console.log error.message

            console.log "blubb", @connection
            @connection.onicecandidate = @handleOwnIce

            @connection.onnegotiationneeded = @handleNegotiation
            @connection.onsignalingstatechange = @handleStateChange

            @connection.onaddstream = @onAddStream
            @connection.onremovestream = @onRemoveStream

            if @createDC
                try
                    @dataChannel = @connection.createDataChannel "p2p",
                        reliable: true
                    @dataChannel.onmessage = @DChandleMessage
                    @dataChannel.onerror   = @DChandleError
                    @dataChannel.onopen    = @DChandleOpen
                    @dataChannel.onclose   = @DChandleClose
                catch error
                    console.log "error creating Data Channel", error.message


            @createOffer()


        handleNegotiation: =>
            console.log "p2pRequest: handleNegotiation" if @debug

        handleStateChange: (e) =>
            console.log "p2pRequest: handleStateChange", e if @debug

        createOffer: =>
            console.log "p2pRequest: createOffer" if @debug

            @connection.createOffer (description) =>
                @connection.setLocalDescription description
                description.requesterId = @userId
                description.resolverId = @resolverId
                description.itemId = @itemId

                @signalSend description

            , null, @sdpConstraints

        handleAnswer: (answer) =>
            console.log "p2pRequest: handleAnswer", answer if @debug
            @connection.setRemoteDescription new RTCSessionDescription(
                answer
            )

        handleOwnIce: (event) =>
            console.log "p2pRequest: handleOwnIce", event if @debug
            if event.candidate
                @signalSend
                    type: "candidate"
                    label: event.candidate.sdpMLineIndex
                    id: event.candidate.sdpMid
                    candidate: event.candidate.candidate
                    requesterId: @userId
                    resolverId: @resolverId
                    itemId: @itemId
            else
                console.log "p2pRequest: handleOwnIce end of candidates"
        handleIceCandidate: (ice) ->
            console.log "p2pRequest: handleIce", ice if @debug
            @connection.addIceCandidate new RTCIceCandidate(
                sdpMLineIndex: ice.label
                candidate: ice.candidate
            )

        onAddStream: (event) =>
            console.log "p2pRequest: onAddStream", event if @debug
            @item.content = event.stream
            @service.$rootScope.$apply() if !@service.$rootScope.$$phase

        onRemoveStream: (event) =>
            console.log "p2pRequest: onRemoveStream", event if @debug
            @item.content = null
            @service.$rootScope.$apply() if !@service.$rootScope.$$phase
            @service.suicide @itemId

        DChandleMessage: (event) =>
            console.log "p2pRequest: DChandleMessage", event if @debug
            @FileService.addChunk @itemId, event.data
        DChandleError: (error) =>
            console.log "p2pRequest: DChandleError", error if @debug
        DChandleOpen: (event) =>
            console.log "p2pRequest: DChandleOpen", event if @debug
            @FileService.initChunkFile @itemId, (success) =>
                if success
                    console.log "successfully created ChunkFile?"
                    @dataChannel.send JSON.stringify
                        itemId: @item.id
                        type: "request"
                else
                    console.log "p2pRequest: failed to create file" if @debug

        DChandleClose: (event) =>
            console.log "p2pRequest: DChandleClose", event if @debug
            # check if file size is correct
            #@FileService.fileComplete @itemId


        signalSend: (msg) ->
            console.log "p2pRequest: signalSend", msg if @debug
            if @isMaster
                for client in @p2p.handler.signallingClients
                    if client.id is msg.resolverId
                        client.DCsend msg
            else
                @p2p.handler.DCsend msg

        handleSignallingMsg: (message) ->
            console.log "p2pRequest: handleSignallingMsg", message if @debug
            switch message.type
                when "answer"
                    @handleAnswer message
                when "candidate"
                    @handleIceCandidate message
                else
                    console.log "p2pRequest: handleSignallingMsg, unknown message type", message


    class P2pResolveConnection
        @::type = "resolver"
        @::debug = false
        @::userId
        @::requesterId
        @::itemId
        @::item
        @::connection
        @::dataChannel
        @::isMaster = false
        @::sdpConstraints = null

        constructor: (@service, @p2p, @itemId, @requesterId) ->
            console.log "p2pResolve: constructor" if @debug
            @item = @service.SharesService.get @itemId
            @FileService = @service.FileService

            @userId = @service.$rootScope.userId

            @isMaster = @service.UserService.getUser(@userId).isMaster


            @connection = new RTCPeerConnection
                iceServers:  @p2p.iceServers
            ,
                null

            @connection.onicecandidate = @handleOwnIce

            @connection.onnegotiationneeded = @handleNegotiation
            @connection.onsignalingstatechange = @handleStateChange

            @connection.onaddstream = @onAddStream
            @connection.onremovestream = @onRemoveStream

            @connection.ondatachannel = @gotDataChannel

            if @item.category is "screen" or @item.category is "webcam"
                @connection.addStream @item.content
            else
                console.log "da file oida"
        handleNegotiation: =>
            console.log "p2pResolve: handleNegotiation" if @debug

        handleStateChange: (e) =>
            console.log "p2pResolve: handleStateChange", e if @debug


        handleOffer: (offer) =>
            console.log "p2pResolve: handleOffer", offer if @debug
            @connection.setRemoteDescription new RTCSessionDescription(offer)
            @createAnswer()

        createAnswer: ->
            console.log "p2pResolve: createAnswer" if @debug
            @connection.createAnswer (description) =>
                @connection.setLocalDescription description
                description.requesterId = @requesterId
                description.resolverId = @userId
                description.itemId = @itemId

                @signalSend description

            , null, @sdpConstraints

        handleOwnIce: (event) =>
            console.log "p2pResolve: handleOwnIce", event if @debug
            console.log "REQUESTERID:" + @requesterId if @debug
            if event.candidate
                @signalSend
                    type: "candidate"
                    label: event.candidate.sdpMLineIndex
                    id: event.candidate.sdpMid
                    candidate: event.candidate.candidate
                    requesterId: @requesterId
                    resolverId: @userId
                    itemId: @itemId
            else
                console.log "p2pResolve: handleOwnIce end of candidates"
        handleIceCandidate: (ice) ->
            console.log "p2pResolve: handleIce", ice if @debug
            @connection.addIceCandidate new RTCIceCandidate(
                sdpMLineIndex: ice.label
                candidate: ice.candidate
            )

        onAddStream: (event) =>
            console.log "p2pResolve: onAddStream", event if @debug

        onRemoveStream: (event) =>
            console.log "p2pResolve: onRemoveStream", event if @debug
            @service.suicide @itemId

        gotDataChannel: (event) =>
            console.log "p2pResolve: gotDataChannel", event if @debug
            @dataChannel = event.channel
            @dataChannel.onmessage = @DChandleMessage
            @dataChannel.onerror   = @DChandleError
            @dataChannel.onopen    = @DChandleOpen
            @dataChannel.onclose   = @DChandleClose

        DChandleMessage: (event) =>
            console.log "p2pResolve: DChandleMessage", event if @debug
            try
                chunkNumber = 0
                parsedMsg = JSON.parse event.data
                if parsedMsg.type is "request"
                    @FileService.getAbChunks(
                        @itemId, (chunk) =>
                            #console.log "chunk '", chunkNumber
                            #++chunkNumber
                            @dataChannel.send chunk
                        =>
                            @suicide @itemId
                            #finished
                            #setTimeout( =>
                            #    @dataChannel.send "finished!!!"
                            #, 1000 )
                    )
            catch e
                console.log "p2pResolve: failed to parse JSON", parsedMsg
        DChandleError: (error) =>
            console.log "p2pResolve: DChandleError", error if @debug
        DChandleOpen: (event) =>
            console.log "p2pResolve: DChandleOpen", event if @debug
        DChandleClose: (event) =>
            console.log "p2pResolve: DChandleClose", event if @debug



        signalSend: (msg) ->
            console.log "p2pResolve: signalSend", msg if @debug
            if @isMaster
                for client in @p2p.handler.signallingClients
                    if client.id is msg.requesterId and msg.itemId is @itemId
                        client.DCsend msg
            else
                @p2p.handler.DCsend msg

        handleSignallingMsg: (message) ->
            console.log "p2pResolve: handleSignallingMsg", message if @debug
            switch message.type
                when "offer"
                    console.log "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
                    @handleOffer message
                when "candidate"
                    @handleIceCandidate message
                else
                    console.log "p2pResolve: handleSignallingMsg, unknown message type", message

    constructor: (@$rootScope, @SharesService, @UserService, @FileService) ->
        console.log "p2pService: constructor", @ if @debug


    setup: (@p2p) ->
        console.log "p2pService: setup", @p2p if @debug

        @$rootScope.$watch =>
            @SharesService.shares
        , (shares) =>
            for p2pConn in @p2pConnections
                found = false
                for share in shares
                    if share.id is p2pConn.itemId
                        found = true
                        break
                if !found
                    @suicide p2pConn.itemId
        , true


    requestItem: (itemId) ->
        console.log "p2pService: requestItem", itemId if @debug

        for p2pConn in @p2pConnections
            if p2pConn.itemId is itemId
                console.log "p2pService: requestItem item found"
                return

        console.log "p2pService: requestItem item not found"
        @p2pConnections.push new P2pRequestConnection(@, @p2p, itemId)

    resolveItem: (itemId, requesterId) ->
        console.log "p2pService: resolveItem", itemId if @debug

        for p2pConn in @p2pConnections
            if p2pConn.itemId is itemId and p2pConn.requesterId is requesterId
                console.log "p2pService: resolveItem item found"
                return

        console.log "p2pService: resolveItem item not found"
        @p2pConnections.push new P2pResolveConnection(@, @p2p, itemId, requesterId)

    suicide: (itemId) ->
        console.log "p2pService: try to killing him softly", itemId if @debug
        for p2pConn, index in @p2pConnections
            if p2pConn.itemId is itemId
                console.log "p2pService: killing him softly", p2pConn if @debug
                p2pConn.connection.close()
                @p2pConnections.splice index, 1
                break


angular.module("unwatched.services").service "P2PService", [
    "$rootScope"
    "SharesService"
    "UserService"
    "FileService"
    P2PService
]
