# Unwatched - User Service
# ============================

"use strict"

app = angular.module "unwatched.services"

class Users
    @::users = []
    @::colors = [
        [125,217,148]
        [203,85,215]
        [223,93,43]
        [55,48,67]
        [120,163,213]
        [199,217,74]
        [144,111,47]
        [95,132,115]
        [211,79,152]
        [130,117,214]
        [220,79,95]
        [206,205,158]
        [93,142,56]
        [104,216,71]
        [127,210,208]
        [134,57,88]
        [206,163,192]
        [59,70,37]
        [112,63,130]
        [91,45,35]
        [197,137,112]
        [215,169,64]
        [80,99,136]
        [153,55,39]
    ]

    class User
        @::isMaster = false
        @::name     = ""
        @::pic      = ""
        @::id       = -1
        @::color    = null
        @::frontendColor = null
        @::joinedDate = null
        @::isActive   = true
        constructor: (@name, @id, @color, @isMaster, @pic = false,
            joinedDate = false) ->
            console.log "new user: " + @name
            @joinedDate = if !joinedDate then new Date() else joinedDate
            if !pic
                @pic = "/images/avatar.png"
                if Math.round(Math.random()) is 0
                    @pic = "/images/avatar_inverted.png"
            @frontendColor = @getColorAsHex()



        getColorAsHex: ->
            "#" +
            @color[0].toString(16) +
            @color[1].toString(16) +
            @color[2].toString(16)
        getColorAsRGB: ->
            "rgb(" +
            @color[0] + "," +
            @color[1] + "," +
            @color[2] + ")"
        getColorWithOpacity: (opacity) ->
            "rgba(" +
            @color[0] + "," +
            @color[1] + "," +
            @color[2] + "," +
            opacity + ")"
        changePic: (@pic) ->
        changeName: (@name) ->

    constructor: (@$rootScope) ->
        style = document.createElement "style"
        style.type = "text/css"
        style.innerHTML = ""
        classes = ""
        for color, index in @colors
            style.innerHTML += ".marker#{index}.ace_start {" +
                "position: absolute;" +
                "z-index: 5;" +
                "border-left: 2px solid rgb(" +
                "#{color[0]},#{color[1]},#{color[2]});" +
                "background-color: rgba(#{color[0]}," +
                "#{color[1]},#{color[2]}, 0.5)}"

        document.getElementsByTagName("head")[0].appendChild style

    getUser: (id) ->
        for user in @users
            if user.id is id
                return user

    delete: (id) ->
        for user, index in @users
            if user.id is id
                @users.splice(id, 1)

    nameIsOccupied: (id, name) ->
        for user in @users
            continue if user.id is id
            if user.name is name
                return true
        return false

    addUser: (name, isMaster = false) ->
        id = @users.length
        tmp_name = @getFirstFreeName(id, name)

        if isMaster
            for user in @users
                return if user.isMaster

        @users.push new User( tmp_name, id, @colors[id], isMaster )

        return id

    addInitUser: (user) ->
        @users.push new User( user.name, user.id, user.color,
            user.isMaster, user.pic, user.joinedDate )

    setInactive: (id) ->
        user = @getUser id
        user.isActive = false
        @$rootScope.$apply() if !@$rootScope.$$phase

    setActive: (id) ->
        user = @getUser id
        user.isActive = true
        @$rootScope.$apply() if !@$rootScope.$$phase

    changeName: (id, newName) ->
        return if @nameIsOccupied( id, newName )
        user = @getUser id
        user.changeName newName
        @$rootScope.$apply() if !@$rootScope.$$phase

    changePic: (id, newPic) ->
        user = @getUser id
        user.changePic newPic
        @$rootScope.$apply() if !@$rootScope.$$phase

    getFirstFreeName: (id, name) ->
        occupied = @nameIsOccupied( id, name )
        counter = 0
        tmp_name = name
        while occupied
            counter++
            tmp_name = name + " (" + counter + ")"
            occupied = @nameIsOccupied( id, tmp_name )

        return tmp_name

app.service "UserService", ["$rootScope", Users ]
