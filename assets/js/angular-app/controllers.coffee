# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "AppCtrl", [
    "$scope", "$rootScope", "SharesService", "StreamService", "ChatService"
    ($scope, $rootScope, SharesService, StreamService, ChatService) ->

        $rootScope.sharesInit = false

        $scope.killStream = (type) ->
            if type is 'screen'
                StreamService.killScreenStream()
            else
                StreamService.killWebcamStream()

]

app.controller "SideCtrl", [
    "$scope", "UserService", "SharesService", "ChatService", "$location",
    "RoomService"
    ($scope, UserService, SharesService, ChatService, $location,
        RoomService) ->

        $scope.isInRoom = RoomService.id != ""
        $scope.roomUrl = "/"

        $scope.$watch ->
            RoomService.id
        , (value) ->
            $scope.isInRoom = RoomService.id != ""
            $scope.roomUrl = "/"
            $scope.roomUrl = "/room" if $scope.isInRoom

        $scope.messages = []
        $scope.users = UserService.users
        $scope.usersNotification = 0

        $scope.$watch ->
            ChatService.messages
        , (messages) ->
            max_messages = messages.length
            max_messages = 4 if messages.length >= 4
            $scope.messages = messages.slice(
                messages.length - max_messages, messages.length
            )
        , true

        $scope.$watch ->
            UserService.users
        , (new_users, old_users) ->
            if new_users.length != old_users.length
                $scope.usersNotification++
        , true

        $scope.$watch ->
            $location.path()
        , (path) ->
            if path is "/users" or path is "/room"
                $scope.usersNotification = 0
        , true



]

app.controller "IndexCtrl", [
    "$scope", "$routeParams", "RTCService", "RoomService", "$location",
    "$rootScope", "UserService", "SharesService",
    ($scope, $routeParams, RTCService, RoomService, $location,
        $rootScope, UserService, SharesService) ->

        window.rtcService = RTCService
        window.userService = UserService
        window.sharesService = SharesService

        $scope.joinAttempt = false
        $scope.inputDisabled = true

        $scope.room = RoomService
        $scope.room.id = ""

        if $routeParams.id
            $scope.joinAttempt = true
            RTCService.setup($routeParams.id)

            $scope.$watch ->
                RTCService.handler.dataChannel
            , (value) ->
                console.log value
                if value
                    $scope.inputDisabled = false
            , true

            $scope.$watch ->
                RTCService.handler.passwordIsValid
            , (value) ->
                if value
                    $location.path "/room"
                else
                    console.log "auth issue", value


        $scope.joinRoom = ->
            if $scope.joinRoomForm.$valid
                # future password validation
                RTCService.checkPassword $scope.room.joinPassword


        $scope.submitRoom = ->
            if $scope.createRoom.$valid
                RTCService.setup()
                RTCService.setPassword $scope.room.password

                $scope.$watch ->
                    RTCService.handler.roomId
                , (value) ->
                    if value && value isnt ''
                        $scope.room.id = value
                        RoomService.setName $scope.room.name
                        RoomService.setUrl( "/room/" + $scope.room.id )
                        $rootScope.userId = UserService.addUser("Unnamed", true)
                        $location.path "/room"

                , true

]

app.controller "RoomCtrl", [
    "$scope", "RoomService", "UserService", "SharesService",
    "ChatStateService", "$routeParams", "RTCService", "$rootScope",
    "$location"
    ($scope, RoomService, UserService, SharesService,
        ChatStateService, $routeParams, RTCService, $rootScope,
        $location) ->

        $scope.isInRoom = RoomService.id isnt ""
        if !$scope.isInRoom
            return

        $scope.room = RoomService

        $scope.user = UserService.getUser( $rootScope.userId )

        if !$scope.user
            $location.path "/"

        console.log "user", $scope.user
        console.log "User is Master: " + $scope.user.isMaster
        $scope.user.borderColor = $scope.user.getColorAsRGB()

        $scope.chat_state = ChatStateService.chat_state

        $scope.$watch ->
            ChatStateService.chat_state
        , (new_state, old_state) ->
            $scope.chat_state = new_state
        , true

        # room infos
        $scope.room.users = UserService.users
        $scope.room.files = SharesService.shares

        # image processing
        $scope.avatar_ready = false
        img = document.createElement("img")
        canvas = document.createElement("canvas")

        $scope.onFileSelect = ($files) ->
            file = $files[0]

            $scope.mime = file.type

            if !(/image\/(gif|jpeg|png)$/i).test(file.type.toString())

                $scope.image_error = "The file you have coosen has a " +
                    "wrong MIME-Type (it has: " + file.type.toString() +
                    "). Please try it again with an image."
                return

            $scope.user.avatar_error = ""

            # read file
            reader = new FileReader()

            reader.onload = (e) ->
                img.src = e.target.result
                $scope.avatar_ready = false

                img.onload = ->
                    img_width = img.width
                    img_height = img.height

                    coord_x = 0
                    coord_y = 0

                    if img_width > img_height
                        coord_x = (img_width - img_height) / 2
                        img_width = img_height
                    else
                        coord_y = (img_height - img_width) / 2
                        img_height = img_width

                    canvas.width = 400
                    canvas.height = 400

                    ctx = canvas.getContext "2d"
                    console.log "processing image: " + coord_x + ", " + coord_y
                    console.log "source boundaries: " + img_width +
                        ", " + img_height

                    ctx.drawImage( img, coord_x, coord_y, img_width, img_height,
                        0, 0, 400, 400 )

                    $scope.user.changePic canvas.toDataURL(
                        $scope.mime
                    )

                    message =
                        userId: $scope.user.id
                        userPic: $scope.user.pic

                    if !$scope.user.isMaster
                        RTCService.sendUserChanges(
                            "userPicHasChanged", message
                        )
                    else
                        RTCService.broadcastUserChanges(
                            "userPicHasChanged", message
                        )

                    $scope.avatar_ready = true
                    $scope.$apply()

            reader.readAsDataURL file

        $scope.checkName = (uName) ->
            # is userName valid?
            if uName.$error.required
                # user name is empty, setting to default
                name = "Unnamed"
            else if uName.$error.minlength
                # user name is too short, fill up with '_'
                name = uName.$viewValue
                i = name.length
                while i < 5
                    name = name += "_"
                    i++
            else
                name = $scope.user.name

            first_free_name = UserService.getFirstFreeName($scope.user.id, name)

            # resetting username if the name was occupied
            $scope.user.name = first_free_name

            message =
                userId: $scope.user.id
                userName: first_free_name

            if !$scope.user.isMaster
                # send new user name
                RTCService.sendUserChanges("userNameHasChanged", message)

            else
                # broadcast new user name
                RTCService.broadcastUserChanges("userNameHasChanged", message)


        # init dummy shares if master
        if $scope.user.isMaster and !$rootScope.sharesInit
            $rootScope.sharesInit = true

            sharedId = undefined
            sharedItem = undefined

            for dummy in dummy_items

                sharedId = SharesService.create( $scope.user.id, dummy.category )
                sharedItem = SharesService.get sharedId

                sharedItem.setName dummy.name
                sharedItem.setSize dummy.size
                sharedItem.setPath dummy.path

                if dummy.extension
                    sharedItem.setExtension dummy.extension

                if dummy.category is "image" or dummy.category is "file"
                    sharedItem.setCreated new Date()

                if dummy.category isnt "code" and dummy.category isnt "note"
                    sharedItem.setThumbnail dummy.thumbnail
                else
                    sharedItem.setContent dummy.content

                console.log sharedItem

]


# ***
# * <h3>Users Controller</h3>
# >
app.controller "UsersCtrl", [
    "$scope", "ChatStateService", "LayoutService", "RoomService", "UserService"
    ($scope, ChatStateService, LayoutService, RoomService, UserService) ->

        $scope.isInRoom = RoomService.id isnt ""
        if !$scope.isInRoom
            return

        $scope.users = UserService.users

        $scope.$watch ->
            ChatStateService.chat_state
        , (new_state, old_state) ->
            $scope.chat_state = new_state
        , true

        $scope.$watch (->
            LayoutService.layout
        ), ((layout) ->
            $scope.controls.layout = layout
        ), true

        $scope.controls = {}
        $scope.controls.sorting = {}
        $scope.controls.sorting.state = ""
        $scope.controls.sorting.ascending = false
        $scope.controls.layout = LayoutService.layout

        $scope.setSortingState = (state) ->
            if $scope.controls.sorting.state is state
                # reset sorting
                if $scope.controls.sorting.ascending
                    $scope.controls.sorting.state = ""
                # switch sorting direction descending/ascending
                $scope.controls.sorting.ascending =
                    !$scope.controls.sorting.ascending
            else
                $scope.controls.sorting.ascending = false
                $scope.controls.sorting.state = state

        $scope.setLayout = (layout) ->
            LayoutService.setLayout(layout)

]

# ***
# * <h3>Share Controller</h3>
# >
app.controller "ShareCtrl", [
    "$scope", "ChatStateService", "SharesService", "LayoutService",
    "$modal", "StreamService"
    ($scope, ChatStateService, SharesService, LayoutService, $modal,
        StreamService) ->

        $scope.shared_items = SharesService.getItems()

        $scope.$watch (->
            return ChatStateService.chat_state
        ), ((new_state, old_state) ->
            $scope.chat_state = new_state
        ), true

        $scope.$watch (->
            LayoutService.layout
        ), ((layout) ->
            $scope.controls.layout = layout
        ), true

        $scope.controls = {}
        $scope.controls.sorting = {}
        $scope.controls.sorting.state = ""
        $scope.controls.sorting.ascending = false
        $scope.controls.layout = LayoutService.layout

        $scope.setSortingState = (state) ->
            if $scope.controls.sorting.state is state
                # reset sorting
                if $scope.controls.sorting.ascending
                    $scope.controls.sorting.state = ""
                # switch sorting direction descending/ascending
                $scope.controls.sorting.ascending =
                    !$scope.controls.sorting.ascending
            else
                $scope.controls.sorting.ascending = false
                $scope.controls.sorting.state = state

        $scope.delete = (item_id) ->

            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        SharesService.get(item_id)
                }
            )

            modalInstance.result.then( ->
                category = SharesService.get(item_id).category
                if category is "screen"
                    StreamService.killScreenStream(category)
                else if category is "webcam"
                    StreamService.killWebcamStream(category)
                else
                    SharesService.delete(item_id)
            )

        $scope.setLayout = (layout) ->
            LayoutService.setLayout(layout)

]

app.controller "DeleteModalInstanceCtrl", [
    "$scope", "$modalInstance", "item"
    ($scope, $modalInstance, item) ->
        $scope.item = item

        $scope.ok = ->
            $modalInstance.close()

        $scope.cancel = ->
            $modalInstance.dismiss('cancel')

]

app.controller "ImageCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$filter",
    "$modal"
    ($scope, $routeParams, SharesService, $location, $filter
        $modal) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharesService.create("image", $rootScope.userId)
            $scope.image_error = ""
            $scope.item.mime_type = ""

            # thumbnail processing
            img = document.createElement("img")
            canvas = document.createElement("canvas")

            $scope.onFileSelect = ($files) ->
                file = $files[0]

                if !(/image\/(gif|jpeg|png)$/i).test(file.type.toString())
                    $scope.image_error = "The file you have coosen has a " +
                        "wrong MIME-Type (it has: " + file.type.toString() +
                        "). Please try it again with an image."
                    return
                $scope.image_error = ""

                $scope.item.size = file.size
                $scope.item.created = $filter("date")(file.lastModifiedDate,
                    "dd.MM.yyyy H:mm")
                $scope.item.uploaded = $filter("date")(new Date(),
                    "dd.MM.yyyy H:mm")
                $scope.item.name = file.name
                $scope.item_name = file.name
                $scope.item.mime_type = file.type

                # read file
                reader = new FileReader()

                reader.onload = (e) ->
                    $scope.item.path = e.target.result
                    img.src = e.target.result

                    img.onload = ->

                        max_width = 300
                        width = img.width
                        height = img.height

                        if width > max_width
                            height *= max_width / width
                            width = max_width

                        canvas.width = width
                        canvas.height = height

                        ctx = canvas.getContext "2d"
                        ctx.drawImage( img, 0, 0, width, height )

                        $scope.item.thumbnail = canvas.toDataURL(
                            $scope.item.mime_type
                        )

                    $scope.$apply()

                reader.readAsDataURL file



        else
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

        # for inline editing
        $scope.disabled = true

        $scope.item_name = $scope.item.name


        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                SharesService.delete($scope.item.id)
                $location.path("/share")
            )
]

app.controller "FileCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$filter",
    "$modal"
    ($scope, $routeParams, SharesService, $location, $filter
        $modal) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharesService.create("file", $rootScope.userId)
            $scope.item.mime_type = ""

            $scope.onFileSelect = ($files) ->
                $scope.file = {}
                $scope.file.progress = 0
                $scope.file.show_progress = false
                $scope.file.ready = false

                $scope.file.source = $files[0]

                $scope.item.size = $scope.file.source.size
                $scope.item.created = $filter("date")(
                    $scope.file.source.lastModifiedDate, "dd.MM.yyyy H:mm")
                $scope.item.uploaded = $filter("date")(new Date(),
                    "dd.MM.yyyy H:mm")

                $scope.item.name = $scope.file.source.name
                $scope.item_name = $scope.file.source.name
                $scope.item.mime_type = $scope.file.source.type


                # read file
                reader = new FileReader()

                reader.onload = (e) ->
                    window.setTimeout((->
                        $scope.file.show_progress = false
                        $scope.file.ready = true
                        $scope.$apply()
                    ), 2000)

                    # console.log file

                    window.requestFileSystem  = window.requestFileSystem ||
                        window.webkitRequestFileSystem

                    window.requestFileSystem window.TEMPORARY,
                        10 * 1024 * 1024,
                        onInitFs,
                        onErrorFs,


                reader.onprogress = (e) ->
                    $scope.file.show_progress = true
                    $scope.$apply()
                    percentLoaded = Math.round((e.loaded / e.total) * 100)
                    $scope.file.progress = percentLoaded

                reader.readAsDataURL $scope.file.source


            onInitFs = (fs) ->
                console.log "created file-system " + fs.name + ":"
                console.log fs

                fs.root.getFile( $scope.item.name,
                    { create: true, exclusive: false }, onCreateFile,
                    onErrorCreateFile )

            onErrorFs = (error) ->
                if error.code is FileError.QUOTA_EXCEEDED_ERR
                    console.log "quota exceeded"

            onCreateFile = (fileEntry) ->
                console.log fileEntry
                fileEntry.createWriter( (fileWriter) ->
                    fileWriter.write($scope.file.source)
                    console.log "wrote file"
                )

            onErrorCreateFile = (error) ->
                console.log error


        else
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

        # for inline editing
        $scope.disabled = true

        $scope.item_name = $scope.item.name


        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                SharesService.delete $scope.item.id
                $location.path "/share"
            )
]

app.controller "NoteCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$modal",
    "$filter"
    ($scope, $routeParams, SharesService, $location, $modal
        $filter) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new note item
            # $scope.item = SharesService.create($rootScope.userId, "note")
            $scope.item = SharesService.get SharesService.create(0, "note")

        else
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

        $scope.text = $scope.item.content

        # tinymce options
        $scope.tinymceOptions = {
            resize: "both"
            height: 400
            handle_event_callback: (e) ->
                console.log e
            onchange_callback: (e) ->
                console.log e
            setup: (editor) ->
                editor.on "change", (e) ->
                    console.log e
                    col = e.level.bookmark.start[0]
                    row = e.level.bookmark.start[2]
        }

        # for inline editing
        $scope.disabled = true
        $scope.item_name = $scope.item.name

        $scope.$watch ->
            $scope.item.name
        , (value) ->
            $scope.item.thumbnail.title = $scope.item.name

        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                SharesService.delete $scope.item.id
                $location.path "/share"
            )

]

app.controller "CodeCtrl", [
    "$scope", "$routeParams", "SharesService", "ChatStateService",
    "available_extensions", "font_sizes", "ace_themes", "$location",
    "AceSettingsService", "$modal", "UserService", "RTCService",
    "$rootScope"
    ($scope, $routeParams, SharesService, ChatStateService,
        available_extensions, font_sizes, ace_themes, $location,
        AceSettingsService, $modal, UserService, RTCService,
        $rootScope) ->

        # init ace editor
        $scope.editor = ace.edit("editor")

        # testing
        # $scope.editor2 = ace.edit("editor2")

        $scope.editor.getSession().setUseWorker(false)
        $scope.editor.session.setNewLineMode("unix")

        # $scope.editor2.getSession().setUseWorker(false)
        # $scope.editor2.session.setNewLineMode("unix")

        # init settings for ace editor
        $scope.settings = {}

        # get available setting options (constants)
        $scope.settings.available_extensions = available_extensions
        $scope.settings.available_font_sizes = font_sizes
        $scope.settings.available_themes = ace_themes

        # helper functions
        $scope.containerResize = ->
            $scope.editor.resize()
            # $scope.editor2.resize()

        $scope.setEditorExtension = (extension) ->
            return if extension is ""
            ace_ext = extension
            ace_ext = "javascript" if extension is "js"
            ace_ext = "ruby" if extension is "rb"
            ace_ext = "python" if extension is "py"
            $scope.editor.getSession().setMode("ace/mode/" + ace_ext)
            # $scope.editor2.getSession().setMode("ace/mode/" + ace_ext)

        $scope.setEditorFontSize = (font_size) ->
            $scope.editor.setFontSize(font_size)
            # $scope.editor2.setFontSize(font_size)
            return

        $scope.setEditorTheme = (theme) ->
            $scope.editor.setTheme("ace/theme/" + theme)
            # $scope.editor2.setTheme("ace/theme/" + theme)
            return

        $scope.getExtensionId = (value) ->
            extension = {}
            for i of $scope.settings.available_extensions
                extension = $scope.settings.available_extensions[i]
                if value is extension.value
                    return i

        $scope.updateThumbnail = ->

            lines = $scope.editor.session.doc.getLines(0, 4)
            i = 0
            thumbnail = ""
            while i < lines.length
                thumbnail += lines[i] + "\n"
                i++

            $scope.item.thumbnail = thumbnail
            console.log "updated thumbnail", @thumbnail


        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                SharesService.delete $scope.item.id
                $location.path "/share"
            )

        $scope.users = UserService.users
        $scope.user = $scope.users[$rootScope.userId]

        if !$routeParams.id?
            # create new code item
            # $scope.item = SharesService.create($rootScope.userId, "code")
            sharedItemId = SharesService.create( $rootScope.userId, "code" )
            $scope.item = SharesService.get( sharedItemId )

            RTCService.sendNewCodeItem $scope.item, $scope.user.isMaster

            contributor = SharesService.getContributor(
                $scope.item.id, $scope.user.id )

        else
            # get shared item by given id
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

            contributor = SharesService.getContributor(
                $scope.item.id, $scope.user.id )

            if !contributor
                $scope.item.contributors.push
                    id: $scope.user.id
                    active: true


        contributor.active = true

        change =
            contributors: $scope.item.contributors
        RTCService.sendCodeItemHasChanged(
            change, $scope.item.id, $scope.user.isMaster )


        Range = ace.require("ace/range").Range
        $rootScope.markers = []

        for contributor in $scope.item.contributors
            if contributor.active
                if contributor.id isnt $scope.user.id
                    $rootScope.markers.push
                        contributorId: contributor.id
                        marker: $scope.editor.session.addMarker(
                            new Range(), "marker" + contributor.id, "text", true
                        )
                        cursor:
                            row: 0
                            col: 0
                    console.log "pushed marker"

        console.log "MARKER", $rootScope.markers
        console.log "ITEM", $scope.item

        # set init value of code and clear predefined selection
        $scope.editor.setValue($scope.item.content)
        $scope.editor.clearSelection()

        # $scope.editor2.setValue($scope.item.getContent())
        # $scope.editor2.clearSelection()

        # for inline editing
        $scope.disabled = true

        # set init coding language, font size and theme
        extension_id = $scope.getExtensionId( $scope.item.extension )

        $scope.settings.extension =
            $scope.settings.available_extensions[extension_id]
        $scope.settings.font_size = AceSettingsService.font_size
        $scope.settings.theme = AceSettingsService.theme

        $scope.setEditorExtension( $scope.settings.extension.value )
        $scope.setEditorFontSize( $scope.settings.font_size.value )
        $scope.setEditorTheme( $scope.settings.theme.value )

        # observe 'change' event
        $scope.editor.session.doc.on 'change', (e) ->
            if !$scope.block

                RTCService.broadcastCodeDocumentHasChanged(
                    e.data,
                    $scope.item.id,
                    $scope.user
                )

            $scope.block = false

            # update model
            $scope.item.content = $scope.editor.getValue()
            $scope.item.size = $scope.editor.session.getLength()
            $scope.$apply() if !$scope.$$phase
            console.log "set size to", $scope.item.size
            $scope.item.last_edited = new Date()

            if e.data.range.start.row <= 5 or e.data.range.end.row <= 5
                $scope.updateThumbnail()
                change =
                    thumbnail: $scope.item.thumbnail
                    content: $scope.item.content
                RTCService.sendCodeItemHasChanged(
                    change, $scope.item.id, $scope.user.isMaster )

        $scope.editor.selection.on "changeCursor", ->
            RTCService.broadcastCursorHasChanged(
                $scope.editor.selection.getCursor(), $scope.user, $scope.item.id
            )


        # watch changes on coding language and update editor
        $scope.$watch "settings.extension", (option, old_option) ->
            if option.value is ""
                $scope.settings.extension = old_option
                return
            $scope.setEditorExtension( option.value )
            $scope.item.extension = option.extension
            change =
                extension: option.extension
            RTCService.sendCodeItemHasChanged(
                change, $scope.item.id, $scope.user.isMaster )
            return

        # watch changes on font size and update editor
        $scope.$watch "settings.font_size", (option) ->
            AceSettingsService.setFontSize(option)
            $scope.setEditorFontSize(option.value)

        # watch changes on theme and update editor
        $scope.$watch "settings.theme", (option) ->
            AceSettingsService.setTheme(option)
            $scope.setEditorTheme(option.value)

        $scope.$watch (->
            return $scope.item.name
        ), ((name) ->
            change =
                name: name
            RTCService.sendCodeItemHasChanged(
                change, $scope.item.id, $scope.user.isMaster )
        ), true

        $scope.$watch (->
            return $scope.item.extension
        ), ((extension) ->
            if $scope.item.extension is $scope.settings.extension.value
                return
            if extension? and extension.length isnt 0
                extension_id = $scope.getExtensionId( $scope.item.extension )

                $scope.settings.extension =
                    $scope.settings.available_extensions[extension_id]
        ), true

        $scope.$watch (->
            return $scope.item.contributors
        ), ((contributors) ->
            for contributor in contributors
                continue if contributor.id is $scope.user.id
                found = false
                for marker, index in $rootScope.markers
                    if marker.contributorId is contributor.id
                        console.log "FOUND"
                        found = true
                        if !contributor.active
                            $scope.editor.session.removeMarker marker.marker
                            $rootScope.markers.splice(index, 1) # remove inactive marker

                if !found and contributor.active
                    $rootScope.markers.push
                        contributorId: contributor.id
                        marker: $scope.editor.session.addMarker(
                            new Range(), "marker" + contributor.id, "text", true
                        )
                        cursor:
                            row: 0
                            col: 0
                    console.log "pushed marker"
                    console.log "MARKERS", $rootScope.markers


        )

        $scope.$watch (->
            return AceSettingsService.font_size
        ), ((font_size) ->
            $scope.settings.font_size = font_size
        ), true

        $scope.$watch (->
            return AceSettingsService.theme
        ), ((theme) ->
            $scope.settings.theme = theme
        ), true

        $scope.$watch (->
            return $scope.item.deltas
        ), ((deltas) ->
            console.log "got new deltas, apply: ", deltas
            if deltas? and deltas.length isnt 0
                $scope.block = true
                $scope.editor.session.doc.applyDeltas [deltas]
                $scope.item.deltas = ""
        ), true

        $rootScope.markersChanged = false

        $scope.$watch (->
            return $rootScope.markers
        ), ((markers) ->
            if $rootScope.markersChanged
                for marker in markers
                    console.log "setting marker"
                    console.log "MAAARKER", marker
                    $scope.editor.session.removeMarker( marker.marker )

                    row = marker.cursor.row
                    col = marker.cursor.column
                    marker.marker = $scope.editor.session.addMarker(
                        new Range(row, col, row, col + 1),
                        "marker" + marker.contributorId, "text", true
                    )
                $rootScope.markersChanged = false
        ), true

        # set contributor to false
        $scope.$on "$routeChangeStart", (scope, next, current) ->

            $rootScope.markers = []

            SharesService.setContributorInactive(current.scope.item.id,
                current.scope.user.id)
            change =
                contributors: current.scope.item.contributors

            RTCService.sendCodeItemHasChanged(
                change, current.scope.item.id, current.scope.user.isMaster )

]

app.controller "ScreenshotCtrl", [
    "$scope", "$routeParams", "SharesService", "$modal", "$location"
    ($scope, $routeParams, SharesService, $modal, $location) ->

        $scope.item = {}

        if $routeParams.id?
            $scope.item = SharesService.get $routeParams.id
            $location.path "/404" if !$scope.item?
        else
            console.log "take new screenshot"


        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                SharesService.delete $scope.item.id
                $location.path "/share"
            )

]

app.controller "ScreenCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$filter",
    "$modal", "StreamService"
    ($scope, $routeParams, SharesService, $location, $filter
        $modal, StreamService) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharesService.create("screen", $rootScope.userId)

        else
            $scope.item = SharesService.get $routeParams.id
            $location.path "/404" if !$scope.item?

        $scope.item.name = $scope.item.author + "'s Shared Screen"
        StreamService.setScreenItemId($scope.item.id)

        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                StreamService.killScreenStream()
                $location.path "/share"
            )
]

app.controller "WebcamCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$filter",
    "$modal", "StreamService"
    ($scope, $routeParams, SharesService, $location, $filter
        $modal, StreamService) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharesService.create("webcam", $rootScope.userId)

        else
            $scope.item = SharesService.get $routeParams.id
            $location.path "/404" if !$scope.item?

        $scope.item.name = $scope.item.author + "'s Shared Webcam"
        StreamService.setWebcamItemId($scope.item.id)

        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                StreamService.killWebcamStream()
                $location.path "/share"
            )
]

# ***
# * <h3>Chat Controller</h3>
# >
app.controller "ChatCtrl", [
    "$scope", "$rootScope", "ChatStateService", "ChatService", "UserService"
    ($scope, $rootScope, ChatStateService, ChatService, UserService) ->
        window.chat = ChatService
        $scope.chat = {}
        $scope.chat.state = ChatStateService.chat_state
        $scope.chat.state_history = ChatStateService.chat_state_history

        $scope.users = UserService.users
        $scope.chat.messages = ChatService.messages
        $scope.userId = $rootScope.userId

        $scope.submitChatMessage = ->
            ChatService.addMessage $scope.chat.message
            $scope.chat.message = ""

        $scope.chat.compress = ->
            $scope.chat.state = "compressed"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.expand = ->
            $scope.chat.state = "expanded"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.minimize = ->
            $scope.chat.state_history = $scope.chat.state
            ChatStateService.setChatStateHistory($scope.chat.state_history)
            $scope.chat.state = "minimized"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.maximize = ->
            if $scope.chat.state is "minimized"
                $scope.chat.state = $scope.chat.state_history
                ChatStateService.setChatState($scope.chat.state_history)

]

dummy_items = [
    {
        category: "screenshot"
        name: "Sophia"
        size: 1036463
        thumbnail: "images/screenshot.png"
        path: "/images/screenshot.png"
    }
    {
        name: "Steffen"
        size: 43696
        category: "file"
        thumbnail: "icon"
        path: "/future/path/to/file"
        extension: "pdf"
    }
    # {
    #     name: "style"
    #     size: 876432
    #     category: "code"
    #     content:
    #         '.newspaper {\n' +
    #         '\t-webkit-column-count:3; /* Chrome, Safari, Opera */\n' +
    #         '\t-moz-column-count:3; /* Firefox */\n' +
    #         '\tcolumn-count:3;\n' +
    #         '\n' +
    #         '\t-webkit-column-gap:40px; /* Chrome, Safari, Opera */\n' +
    #         '\t-moz-column-gap:40px; /* Firefox */\n' +
    #         '\tcolumn-gap:40px;\n' +
    #         '\n' +
    #         '\t-webkit-column-rule:4px outset #ff00ff; /* Chrome, Safari,Opera */\n' +
    #         '\t-moz-column-rule:4px outset #ff00ff; /* Firefox */\n' +
    #         '\tcolumn-rule:4px outset #ff00ff;\n' +
    #         '}\n'
    #     path: "/future/path/to/file"
    #     extension: "css"
    # }
    # {
    #     name: "HelloWorld"
    #     size: 346432
    #     category: "code"
    #     content:
    #         'import java.io.IOException\n' +
    #         'import java.util.Map\n' +
    #         '\n' +
    #         'public class MyFirstJavaProgram {\n' +
    #         '\tpublic static void main(String[] args) {\n' +
    #         '\t\tSystem.out.println("Hello World");\n' +
    #         '\t}\n' +
    #         '}\n' +
    #         '\n'
    #     path: "/future/path/to/file"
    #     extension: "java"
    # }
    # {
    #     name: "main"
    #     size: 832
    #     category: "code"
    #     content:
    #         'var x = myFunction(4, 3); // Function is called, return value will end up in x\n' +
    #         'function myFunction(a, b) {\n' +
    #         '\treturn a * b; // Function returns the product of a and b\n' +
    #         '}\n'
    #     path: "/future/path/to/file"
    #     extension: "js"
    # }
    # {
    #     name: "index"
    #     size: 876432
    #     category: "code"
    #     content:
    #         '!doctype html>\n' +
    #         '<html lang="en">\n' +
    #         '\t<head>\n' +
    #         '\t\t<meta charset="utf-8">\n' +
    #         '\t\t<title>The HTML5 Herald</title>\n' +
    #         '\t\t<meta name="description" content="The HTML5 Herald">\n' +
    #         '\t\t<meta name="author" content="SitePoint">\n' +
    #         '\t\t<link rel="stylesheet" href="css/styles.css?v=1.0">\n' +
    #         '\t</head>\n' +
    #         '\t<body>\n' +
    #         '\t\t<script src="js/scripts.js"></script>\n' +
    #         '\t</body>\n' +
    #         '</html>\n'
    #     path: "/future/path/to/file"
    #     extension: "html"
    # }
    # {
    #     name: "script"
    #     size: 1024
    #     category: "code"
    #     content:
    #         "parents, babies = (1, 1)\n" +
    #         "\n" +
    #         "while babies < 100:\n" +
    #         "\tprint 'This generation has {0} babies'.format(babies)\n" +
    #         "\tparents, babies = (babies, parents + babies)'\n"
    #     path: "/future/path/to/file"
    #     extension: "py"
    # }
    # {
    #     name: "spec"
    #     size: 90123
    #     category: "code"
    #     content:
    #         'for j in 1..5 do\n' +
    #         '\tfor i in 1..5 do\n' +
    #         '\t\tprint i,  " "\n' +
    #         '\t\tbreak if i == 2\n' +
    #         '\tend\n' +
    #         'end\n'
    #     path: "/future/path/to/file"
    #     extension: "rb"
    # }
    {
        name: "Protocol"
        size: 90123
        category: "note"
        content:
            "<p>Loremipsumdolorsitamet, consetetursadipscingelitr, " +
            "seddiamnonumyeirmod.</p><p>temporinvidun tutlaboreet dolorem " +
            "agnaaliquy amerat, seddiamvoluptua.</p>"
        path: "/future/path/to/file"
    }
    {
        name: "How to photoshop"
        size: 0
        category: "screen"
        thumbnail: "screenshot-screen.png"
    }
    {
        name: "See me cooking"
        size: 0
        category: "webcam"
        thumbnail: "screenshot-webcam.jpg"
    }
    {
        name: "Cute Cat Picture"
        size: 190123
        thumbnail: "images/image.jpg"
        category: "image"
        path: "/images/image.jpg"
    }

]

app.controller "StreamCtrl", [
    "$scope", "StreamService"
    ($scope, StreamService) ->

        $scope.killStream = (type) ->
            if type is 'screen'
                StreamService.killScreenStream()
            else
                StreamService.killWebcamStream()
]
