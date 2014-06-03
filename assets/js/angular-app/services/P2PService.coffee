# Unwatched - PTP Factory
# ============================

"use strict"



class P2PService
    @::debug = true
    @::p2p
    @::p2pConnections = []

    class P2pRequestConnection
        @::type = "requester"
        @::debug = true
        @::userId
        @::resolverId
        @::itemId
        @::item
        @::connection
        @::dataChannel
        @::isMaster = false
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

            if @item.category is "file"
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

            @connection.ondatachannel = @gotDataChannel

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

        gotDataChannel: (event) =>
            console.log "p2pRequest: gotDataChannel", event if @debug
            @dataChannel = event.channel
            @dataChannel.onmessage = @DChandleMessage
            @dataChannel.onerror   = @DChandleError
            @dataChannel.onopen    = @DChandleOpen
            @dataChannel.onclose   = @DChandleClose

        DChandleMessage: (event) =>
            console.log "p2pRequest: DChandleMessage", event if @debug
        DChandleError: (error) =>
            console.log "p2pRequest: DChandleError", error if @debug
        DChandleOpen: (event) =>
            console.log "p2pRequest: DChandleOpen", event if @debug
        DChandleClose: (event) =>
            console.log "p2pRequest: DChandleClose", event if @debug



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
        @::debug = true
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

            if @item.category isnt "file"
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

        DChandleMessage: (event) =>
            console.log "p2pResolve: DChandleMessage", event if @debug
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
                    @handleOffer message
                when "candidate"
                    @handleIceCandidate message
                else
                    console.log "p2pResolve: handleSignallingMsg, unknown message type", message

    constructor: (@$rootScope, @SharesService, @UserService) ->
        console.log "p2pService: constructor", @ if @debug

    setup: (@p2p) ->
        console.log "p2pService: setup", @p2p if @debug

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
        for p2pConn, index in @p2pConnection
            if p2pConn.itemId is itemId
                console.log "p2pService: killing him softly", p2pConn if @debug
                @p2pConnection.splice index, 1
                break

angular.module("unwatched.services").service "P2PService", [
    "$rootScope"
    "SharesService"
    "UserService"
    P2PService
]
        # directly shared?
        # --> webcam --> audio/video
        # --> screen --> audio/video
        # --> files  --> DataChannel only

        # what happens?
        # a user requests a file from an other user,
        # so he sends a request for a p2p connection to the master
        #
        # something like
        #   type: "p2p"
        #   userId: 12
        #   fileId: 12345
        #
        # master sends this message to the resolver
        # resolver sends back an offer , master sends it to user
        # user sends back an answer to master, master sends it to resolver
        # ice exchange
        #
        # after this, both peers talk to each other via datachannel and handle the request
        # everthing should happen automaticaly, cause

    #window.getP2P = ->








###







        new class P2P
            @::debug          = true
            @::signaller      = null
            @::isOfferer      = true
            @::signalServer   = null
            @::connection     = null
            @::id             = null
            @::sdpConstraints =
                optional: []
                mandatory:
                    OfferToReceiveAudio: true
                    OfferToReceiveVideo: true
            @::streamOptions = [
                RtpDataChannels: true
            ]
            constructor: () ->

            setup: -> (@signaller, @requestUserId, @fileId, @isOfferer = true, @dataOnly = true) ->
                console.log "P2P setup" if @debug

                if @dataOnly
                    @streamOptions = null
                    @sdpConstraints = null


                @connection = new RTCPeerConnection(
                    iceServers:  @signaller.iceServers
                ,
                    @streamOptions
                )
                @connection.onicecandidate = @handleOwnIce

                @connection.onnegotiationneeded = @handleNegotiation
                @connection.onsignalingstatechange = @handleStateChange

                @connection.onaddstream = @onAddStream
                @connection.onremovestream = @onRemoveStream

                @connection.ondatachannel = @gotDataChannel

            signalSend: (msg) ->
                if @signalConnection.readyState is 1
                    @signalConnection.send JSON.stringify(msg)
                else
                    console.log "Signalling Channel isn't ready"
                    setTimeout =>
                        @signalSend msg
                    , 25
            handleSignalOpen: (event) ->
                console.log "Signalling Channel Opened"
            handleSignalMessage: (event) =>
                console.log "got message!", event.data if @debug
                try
                    parsedMsg = JSON.parse(event.data)

                    if !parsedMsg.type
                        throw new Error("message Type not defined")

                    switch parsedMsg.type
                        when "offer"
                            @handleOffer( parsedMsg )
                        when "answer"
                            @handleAnswer( parsedMsg )
                        when "candidate"
                            @handleIce( parsedMsg )
                        else
                            console.log "other message"
                            console.log parsedMsg
                catch e
                    console.log "wasn't able to parse message"
                    console.log e.message
            handleSignalError: (event) ->
                console.log "Signalling Channel Error"
                console.log event
            handleSignalClose: (event) ->
                console.log "Signalling Channel Closed"
            handleOwnIce: (event) =>
                console.log "handleOwnIce" if @debug
                if event.candidate
                    @signalSend
                        type: "candidate"
                        label: event.candidate.sdpMLineIndex
                        id: event.candidate.sdpMid
                        candidate: event.candidate.candidate
                        shareId: @id
                else
                    console.log "end of candidates"
            handleIce: (ice) ->
                console.log "handleIce" if @debug
                @connection.addIceCandidate new RTCIceCandidate(
                    sdpMLineIndex: ice.label
                    candidate: ice.candidate
                )
            handleOffer: (offer) =>
                console.log "handle offer" if @debug
                @connection.setRemoteDescription new RTCSessionDescription(offer)
                @createAnswer()
            createAnswer: ->
                console.log "create answer" if @debug
                @connection.createAnswer (description) =>
                    @connection.setLocalDescription description
                    description.clientId = @id
                    console.log @id if @debug
                    console.log "answer sent?" if @debug
                    @signalSend description
                , null, @sdpConstraints
            createOffer: ->
                console.log "create offer" if @debug
                @connection.createOffer (description) =>
                    @connection.setLocalDescription description
                    description.clientId = @id
                    @signalSend description
                , null, @sdpConstraints
            handleAnswer: (answer) ->
                console.log "handle answer", answer if @debug
                @connection.setRemoteDescription new RTCSessionDescription(
                    answer
                )
            handleNegotiation: ->
                console.log "handleNegotiation"
                if @isOfferer
                    createoffer()
                    try
                        @dataChannel = @connection.createDataChannel "control",
                            reliable: false
                        @dataChannel.onmessage = @DChandleMessage
                        @dataChannel.onerror   = @DChandleError
                        @dataChannel.onopen    = @DChandleOpen
                        @dataChannel.onclose   = @DChandleClose
                    catch error
                        console.log "error creating Data Channel", error.message
            handleStateChange: ->
                console.log "stateChange"
            onAddStream: ->
                console.log "stream added"
            onRemoveStream: ->
                console.log "stream removed"
            gotDataChannel: (event) =>
                console.log "RTConnection gotDataChannel"
                @dataChannel = event.channel
                @dataChannel.onmessage = @DChandleMessage
                @dataChannel.onerror   = @DChandleError
                @dataChannel.onopen    = @DChandleOpen
                @dataChannel.onclose   = @DChandleClose

            DChandleMessage: (msg) =>
                console.log "got a message from DC",
                console.log msg


                parsedMsg = JSON.parse(msg.data)
                console.log "parsed"
                console.log parsedMsg
                switch parsedMsg.type#
                    when ""
                    else
                        console.log "DChandle: unknown msg"
            DChandleError: (error) ->
                console.log "got an DC error!", error
            DChandleOpen: =>
                console.log "DC is open!"
            DChandleClose: ->
                console.log "DC is closed!"
            DCsend: (message) ->
                #messages =
                console.log "DCsend", message
                @dataChannel.send JSON.stringify(message)


]
###
