# Unwatched - Angular Services
# ============================

"use strict"

class Client
    name: null
    eMail: null
    hash: null
    connections: []
    constructor: (@name, @email) ->


class RTConnection
    servers:
        iceServers: [
            url: "stun:stun.l.google.com:19302"
        ]
        connectionServer: "localhost"
    constructor: ->
    createOffer: ->
    createAnswer: ->
    onIce: ->
    addReliableChannel: ->
    addUnreliableChannel: ->



class RTCProvider
    @::isMaster   = true
    @::name       = ""
    @::clients    = []
    @::moderators = []
    @::signalServer = "wss://localhost"
    # exposed to .config
    constructor: ->
    setSignalServer: (@signalServer) ->
        console.log "set Signal Server: " + signalServer
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

    @chat_state = "compressed"
    @chat_state_history = ""

    @setChatState = (chat_state) ->
        @chat_state = chat_state

    @setChatStateHistory = (chat_state_history) ->
        @chat_state_history = chat_state_history

    return
