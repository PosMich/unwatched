# Unwatched - PTP Factory
# ============================

"use strict"

angular.module("unwatched.services").factory "P2PFactory", [
    "SharesService",
    "RTCService",
    (SharesService, RTCService) ->
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
