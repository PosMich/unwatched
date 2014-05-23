# Unwatched - Angular Services
# ============================

"use strict"

class Client
    name: null
    eMail: null
    id: null
    connections: []
    constructor: (@name, @email) ->
    get: ->

class Signaler 
    @channel = null
    constructor: (@channel) ->
    createNew: (type) ->
        type: "new"
        newType: "share"
        id: ""


class RTConnection
    @id = null
    @isInitiator = false
    @isStarted = false
    @pcConfig =
        iceServers: [
            url: "stun:stun.l.google.com:19302"
        ]
    @pcConstraints = 
        optional: [
            { DtlsSrtpKeyAgreement: true }
            { RtpDataChannels: true }
        ]
    @sdpConstraints = 
        mandatory:
            OfferToReceiveAudio: true
            OfferToReceiveVideo: true
    @dataChannelOptions = 
        ordered: false
        maxRetransmitTime: 3000
        #maxRetransmits: 
        #protocol:
        #negotiated:
        #id:
    @peerConnection = null
    @dataChannel = null
    @signalChannel = null
    constructor: (@signalChannel, @id = null, @type = "share") -> 
        console.log "id: "+@id
        console.log "type: "+@type
        @signalChannel.onmessage = @handleSignalChannelMessage
        if !@id 
            console.log "id is undefined"
            @delayedSignalChannelSend()
        console.log "RTConnection constructor"
    delayedSignalChannelSend: =>
        console.log "deeelaayyyyeeed"
        console.log @signalChannel
        if @signalChannel.readyState is 1

            @signalChannel.send JSON.stringify( 
                type: "new"
                newType: "share"
            )
        else
            setTimeout @delayedSignalChannelSend, 100
    startConnection: ->
        console.log "RTConnection startConnection"
        try 
            @peerConnection = new window.RTCPeerConnection(@pcConfig, @pcConstraints)
            @peerConnection.onicecandidate = @handleIceCandidate
        catch error
            console.log "error creating peerConnection"
            console.log error.message

        @peerConnection.onaddstream = @remoteStreamAdded
        @peerConnection.onremovestream = @remoteStreamRemoved
        
        if @isInitiator
            @addDataChannel
        else
            @peerConnection.ondatachannel = @gotDataChannel

        @isStarted = true
        return
    addDataChannel: ->
        console.log "RTConnection addDataChannel"
        try
            @dataChannel = @peerConnection.createDataChannel("testLabel", @dataChannelOptions)
            @dataChannel.onmessage = @DChandleMessage
            @dataChannel.onerror   = @DChandleError
            @dataChannel.onopen    = @DChandleOpen
            @dataChannel.onclose   = @DChandleClose
        catch error
            console.log "error creating Data Channel"
            console.log error.message
    gotDataChannel: (event) ->
        console.log "RTConnection gotDataChannel"
        @dataChannel = event.channel
        @dataChannel.onmessage = @handleMessage
        @dataChannel.onerror   = @handleError
        @dataChannel.onopen    = @handleOpen
        @dataChannel.onclose   = @handleClose
    DChandleMessage: (msg)->
        console.log "DataChannel message"
        console.log JSON.parse(msg)
    DCHandleError: (error)->
        console.log "DataChannel Error"
        console.log error
    DChandleOpen: ->
        console.log "DataChannel opened"
    DChandleClose: ->
        console.log "DataChannel closed"
    handleIceCandidate: (event) ->
        console.log "RTConnection handleIceCandidate"
        if event.candidate
            @signalChannel.send
                type: "candidate"
                label: event.candidate.sdpMLineIndex
                id: event.candidate.sdpMid
                candidate: event.candidate.candidate
        else
            console.log "end of candidates"
    doOffer: ->
        console.log "RTConnection startCall"
        @peerConnection.createOffer @setLocalSdpSend, null, @sdpConstraints
    doAnswer: ->
        console.log "RTConnection doAnswer"
        @peerConnection.createAnswer setLocalAndSendMessage, null, @sdpConstraints
    setLocalSdpSendBack: (sessionDescription)->
        console.log "RTConnection setLocalSdpSendBack"
        @peerConnection.setLocalDescription sessionDescription
        @signalChannel.send sessionDescription
    handleSignalChannelMessage: (message)->
        console.log "RTConnection handleSignalChannelMessage"
        console.log "Received message:", message
        
        if message.type is "offer"
            @startConnection() if not @isInitiator and not @isStarted
            @peerConnection.setRemoteDescription new RTCSessionDescription(message)
            @doAnswer()
        else if message.type is "answer" and @isStarted
            @peerConnection.setRemoteDescription new RTCSessionDescription(message)
        else if message.type is "candidate" and @isStarted
            candidate = new RTCIceCandidate(
                sdpMLineIndex: message.label
                candidate: message.candidate
            )
            @peerConnection.addIceCandidate candidate
        #else handleRemoteHangup()  if message is "bye" and @isStarted
        else 
            console.log "got unknown msg"
            console.log message

window.RTConnection = RTConnection
#(new WebSocket("wss://localhost:3001"))

class RTCProvider
    @::isMaster   = true
    @::name       = ""
    @::clients    = []
    @::moderators = []
    @::signalServer = "wss://localhost:3001" 
    
    @::wss          = null
    @::room         = null
    # exposed to .config
    constructor: ->

    setSignalServer: (@signalServer)->
        console.log "set Signal Server: "+signalServer
        console.log "RTCPeerConnection:"
        console.log window.RTCPeerConnection
        console.log "getUserMedia:" 
        console.log window.getUserMedia
        console.log "attachMediaStraem:" 
        console.log window.attachMediaStream
        console.log "reattachMediaStream" 
        console.log window.reattachMediaStream
        console.log "webrtcDetectedBrowser" 
        console.log window.webrtcDetectedBrowser
        console.log "webrtcDetectedVersion" 
        console.log window.webrtcDetectedVersion
        console.log "isWebrtcAble" 
        console.log window.isWebrtcAble
        return
    connect: ->
        wss = new WebSocket @signalServer
        wss.onopen = ->
            console.log "wss open"
        
        wss.onerror = (error) ->
            console.log "wss error"
            console.log error
        wss.onmessage = (msg) ->
            console.log "wss msg received"
            console.log JSON.parse(msg)

        wss.onclose = ->
        
    newRoom: (name) ->
    newShare: (type) ->

    connectToRoom: ->

    connectToShare: ->
    
    setName: (@name) ->
        console.log "inner set Name: " + name
    addClients: (name, eMail) ->
        console.log "+++ addClients"
        console.log @clients
        console.log @name
        @clients.push new Client(name, eMail)
        console.log "--- addClients"
    getClients: ->
        console.log "+++ getClients"
        console.log @clients
        console.log "--- getClients"
    # exposed to everyone
    $get: ->
        logName: ->
            console.log "+++ logName"
            console.log "Hello " + @name
            console.log "--- logName"
        createHash: ->
            return "HAAASh"
        setName: (@name) ->
            console.log "set name to: " + name
        addClient: (name, eMail) =>
            console.log "+++ addClient"
            @addClients name, eMail
            console.log "--- addClient"
        listClients: ->
            console.log "+++ listClients"
            console.log @
            console.log @name
            console.log @clients
            console.log "--- listClients"
            #@getClients()
            #console.log @asdf
            #console.log "bluuuuuu"
            #console.log @clients


app = angular.module "unwatched.services", []

app.provider "RTC", RTCProvider

app.value "version", "0.1"

app.service "ChatStateService", ->

    @chat_state = "minimized"
    @chat_state_history = "compressed"

    @setChatState = (chat_state) ->
        @chat_state = chat_state

    @setChatStateHistory = (chat_state_history) ->
        @chat_state_history = chat_state_history

    return

app.service "SharedItemsService", ->

    @items = []

    getItemIndex = (id) =>
        item = {}
        for i of @items
            item = @items[i]
            if item.id is parseInt(id)
                return i

    @initItems = (items_arr) ->
        @items = items_arr

    @getItems = ->
        @items

    @getItem = (id) -> 
        @items[ getItemIndex(id) ]

    @deleteItem = (id) ->
        @items.splice( getItemIndex(id), 1 )

    return

