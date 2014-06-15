# Unwatched - Angular Services
# ============================

"use strict"

app = angular.module "unwatched.services"

app.service "ChatService", [
    "$rootScope",
    class Messages
        @::messages = []
        class Message
            @::sent_at
            constructor: (@sender, @message) ->
                @sent_at = new Date()

        constructor: (@$rootScope) ->

        addMessage: (message, sender = @$rootScope.userId) ->
            @messages.push new Message(sender, message)
            @$rootScope.$apply() if !@$rootScope.$$phase
]

app.service "RoomService", [
    "$rootScope"
    "$http"
    "SERVER"
    "SERVER_PORT"
    class Room
        @::id = ""
        @::name
        @::created
        @::usersLength
        @::filesLength
        @::description
        @::url = ""
        @::isClosed = false

        constructor: (@$rootScope, @$http, @SERVER, @SERVER_PORT) ->
            @created = new Date()
            @description = "Room description"
            isClose = false

        setName: (name) ->
            @name = name

        setUrl: (longUrl) ->
            @$http.post(
                "https://www.googleapis.com/urlshortener/v1/url?"
                longUrl: "https://" + @SERVER + ":" + @SERVER_PORT + longUrl
            ).success (data) =>
                @url = data.id
]


app.service "ChatStateService", ->
    @chat_state = "minimized"
    @chat_state_history = "compressed"

    @setChatState = (chat_state) ->
        @chat_state = chat_state

    @setChatStateHistory = (chat_state_history) ->
        @chat_state_history = chat_state_history

    return


app.service "LayoutService", ->
    @layout = "layout-icons"

    @setLayout = (layout) ->
        @layout = layout

    return


app.service "AceSettingsService", [
    "font_sizes", "ace_themes"
    (font_sizes, ace_themes) ->

        @font_size = font_sizes[1]
        @theme = ace_themes[0]

        @setFontSize = (font_size) ->
            @font_size = font_size

        @setTheme = (theme) ->
            @theme = theme


        return
]


app.constant "available_extensions", [
    { value: "", name: "Choose language", extension: "" }
    { value: "html", name: "HTML", extension: "html" }
    { value: "css", name: "CSS", extension: "css" }
    { value: "js", name: "JavaScript", extension: "js" }
    { value: "java", name: "Java", extension: "java" }
    { value: "rb", name: "Ruby", extension: "rb" }
    { value: "py", name: "Python", extension: "py" }
]


app.constant "font_sizes", [
    { value: 12, name: "12px"}
    { value: 14, name: "14px"}
    { value: 16, name: "16px"}
    { value: 18, name: "18px"}
    { value: 20, name: "20px"}
]


app.constant "ace_themes", [
    { value: "monokai", name: "Monokai"}
    { value: "github", name: "Github"}
    { value: "ambiance", name: "Ambiance"}
    { value: "mono_industrial", name: "Mono Industrial"}
    { value: "terminal", name: "Terminal"}
]


app.constant "SERVER", "unwatched.multimediatechnology.at"
app.constant "SERVER_PORT", "443"


app.value "ICE_SERVERS", [
        { urls: "stun:stun.l.google.com:19302"}
        # { urls: "stun.turnservers.com:3478" }
        {
            urls: []
            "credential": ""
            "username": ""
        }
    ]
