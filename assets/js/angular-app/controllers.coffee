# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "AppCtrl", [
    "$scope", "SharedItemsService", "StreamService"
    ($scope, SharedItemsService, StreamService) ->

        SharedItemsService.initItems( dummy_items )

        $scope.killStream = (type) ->
            if type is 'screen'
                StreamService.killScreenStream()
            else
                StreamService.killWebcamStream()

]

app.controller "IndexCtrl", [
    "$scope", "$routeParams", "RTCService", "RoomService", "$location", 
    "$rootScope", "UserService"
    ($scope, $routeParams, RTCService, RoomService, $location, 
        $rootScope, UserService) ->

        window.rtc = RTCService

        $scope.joinAttempt = false
        $scope.inputDisabled = true

        if $routeParams.id
            $scope.joinAttempt = true
            RTCService.setup($routeParams.id)
            
            $scope.$watch ->
                RTCService.handler.dataChannel
            , (value) ->
                console.log value
                if value
                    console.log "inputDisabled"
                    $scope.inputDisabled = false
            , true

        $scope.room = RoomService
        $scope.room.id = ""


        $scope.joinRoom = ->
            console.log "fn"
            if $scope.joinRoomForm.$valid
                # future password validation
                $rootScope.userId = UserService.addUser("Unnamed")
                $location.path("/room")


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
                        $location.path("/room")

                , true

]

app.controller "RoomCtrl", [
    "$scope", "RoomService", "UserService", "SharedItemsService", 
    "ChatStateService", "$routeParams", "RTCService", "$rootScope"
    ($scope, RoomService, UserService, SharedItemsService, 
        ChatStateService, $routeParams, RTCService, $rootScope) ->

        $scope.room = RoomService
        
        console.log "userId: " + $rootScope.userId
        $scope.user = UserService.getUser( $rootScope.userId )
        console.log "user", $scope.user
        console.log "User is Master: " + $scope.user.isMaster
        $scope.user.changePic "/images/avatar.png"
        $scope.user.borderColor = $scope.user.getColorAsRGB()

        $scope.chat_state = ChatStateService.chat_state
        $scope.disabled = true
        $scope.description = $scope.room.description

        $scope.$watch ->
            ChatStateService.chat_state
        , (new_state, old_state) ->
            $scope.chat_state = new_state
        , true

        # room infos
        $scope.room.users = UserService.users
        # $scope.room.usersLength = $scope.room.users.length
        $scope.room.filesLength = SharedItemsService.items.length

        # image processing
        img = document.createElement("img")
        canvas = document.createElement("canvas")

        $scope.onFileSelect = ($files)->
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
                    console.log "source boundaries: " + img_width + ", " + img_height

                    ctx.drawImage( img, coord_x, coord_y, img_width, img_height,
                        0, 0, 400, 400 )

                    $scope.user.changePic canvas.toDataURL(
                        $scope.mime
                    )

                    $scope.$apply()

            reader.readAsDataURL file

]


# ***
# * <h3>Member Controller</h3>
# >
app.controller "MembersCtrl", [
    "$scope", "ChatStateService", "LayoutService"
    ($scope, ChatStateService, LayoutService) ->
        $scope.members = []

        $scope.$watch ->
            ChatStateService.chat_state
        , (new_state, old_state) ->
            $scope.chat_state = new_state
        , true

        membersAmount = Math.floor(Math.random() * 10 + 1) + 6
        while membersAmount -= 1
            $scope.members.push
                name: "Lorem Ipsum"
                avatar:
                    if Math.round(Math.random()) is 0 then "/images/avatar.png"
                    else "/images/avatar_inverted.png"
]

# ***
# * <h3>Share Controller</h3>
# >
app.controller "ShareCtrl", [
    "$scope", "ChatStateService", "SharedItemsService", "LayoutService",
    "$modal", "StreamService"
    ($scope, ChatStateService, SharedItemsService, LayoutService, $modal,
        StreamService) ->
        $scope.shared_items = []

        $scope.$watch (->
            return ChatStateService.chat_state
        ), ((new_state, old_state) ->
            $scope.chat_state = new_state
        ), true

        $scope.$watch (->
            return LayoutService.layout
        ), ((layout) ->
            $scope.controls.layout = layout
        ), true

        $scope.controls = {}
        $scope.controls.sorting = {}
        $scope.controls.sorting.state = "name"
        $scope.controls.sorting.ascending = false
        $scope.controls.layout = LayoutService.layout

        $scope.shared_items = SharedItemsService.getItems()

        $scope.setSortingState = (state) ->
            if $scope.controls.sorting.state is state
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
                        SharedItemsService.get(item_id)
                }
            )

            modalInstance.result.then( ->
                category = SharedItemsService.get(item_id).category
                if category is "screen"
                    StreamService.killScreenStream(category)
                else if category is "webcam"
                    StreamService.killWebcamStream(category)
                else
                    SharedItemsService.delete(item_id)
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
    "$scope", "$routeParams", "SharedItemsService", "$location", "$filter",
    "$modal"
    ($scope, $routeParams, SharedItemsService, $location, $filter
        $modal) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharedItemsService.create("image")
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
            $scope.item = SharedItemsService.get($routeParams.id)
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
                SharedItemsService.delete($scope.item.id)
                $location.path("/share")
            )
]

app.controller "FileCtrl", [
    "$scope", "$routeParams", "SharedItemsService", "$location", "$filter",
    "$modal"
    ($scope, $routeParams, SharedItemsService, $location, $filter
        $modal) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharedItemsService.create("file")
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
            $scope.item = SharedItemsService.get($routeParams.id)
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
                SharedItemsService.delete($scope.item.id)
                $location.path("/share")
            )
]

app.controller "NoteCtrl", [
    "$scope", "$routeParams", "SharedItemsService", "$location", "$modal",
    "$filter"
    ($scope, $routeParams, SharedItemsService, $location, $modal
        $filter) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new note item
            $scope.item = SharedItemsService.create("note")
            $scope.item.thumbnail = {}
            $scope.item.thumbnail.title = ""
            $scope.item.thumbnail.content = ""
            $scope.item.content = ""

        else
            $scope.item = SharedItemsService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

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
                    # update thumbnail
                    $scope.item.thumbnail.content =
                        e.level.content.substr(0, 300)
                    # update last edited date
                    $scope.item.last_edited =
                        $filter("date")(new Date(), "dd.MM.yyyy H:mm")

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
                SharedItemsService.delete($scope.item.id)
                $location.path("/share")
            )

]

app.controller "CodeCtrl", [
    "$scope", "$routeParams", "SharedItemsService", "ChatStateService",
    "available_extensions", "font_sizes", "ace_themes", "$location",
    "AceSettingsService", "$modal"
    ($scope, $routeParams, SharedItemsService, ChatStateService,
        available_extensions, font_sizes, ace_themes, $location,
        AceSettingsService, $modal) ->

        # init ace editor
        $scope.editor = ace.edit("editor")
        $scope.editor.getSession().setUseWorker(false)
        $scope.editor.session.setNewLineMode("unix")

        # init settings for ace editor
        $scope.settings = {}

        # get available setting options (constants)
        $scope.settings.available_extensions = available_extensions
        $scope.settings.available_font_sizes = font_sizes
        $scope.settings.available_themes = ace_themes

        # helper functions
        $scope.containerResize = ->
            $scope.editor.resize()

        $scope.setEditorExtension = (extension) ->
            return if extension is ""
            ace_ext = extension
            ace_ext = "javascript" if extension is "js"
            ace_ext = "ruby" if extension is "rb"
            ace_ext = "python" if extension is "py"
            $scope.editor.getSession().setMode("ace/mode/" + ace_ext)

        $scope.setEditorFontSize = (font_size) ->
            $scope.editor.setFontSize(font_size)
            return

        $scope.setEditorTheme = (theme) ->
            $scope.editor.setTheme("ace/theme/" + theme)
            return

        $scope.getExtensionId = (value) ->
            extension = {}
            for i of $scope.settings.available_extensions
                extension = $scope.settings.available_extensions[i]
                if value is extension.value
                    return i

        $scope.getThumbnail = ->
            thumbnail = ""
            lines = $scope.editor.session.doc.getAllLines()
            i = 0
            while i < 5
                if lines[i]?
                    line_string = lines[i]
                    thumbnail += line_string
                    thumbnail += "\n" if i < 4
                i++

            thumbnail

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
                SharedItemsService.delete($scope.item.id)
                $location.path("/share")
            )

        if !$routeParams.id?
            # create new code item
            $scope.item = SharedItemsService.create("code")

        else
            # get shared item by given id
            $scope.item = SharedItemsService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

            $scope.item_name = $scope.item.name

            # set init value of code and clear predefined selection
            $scope.editor.setValue($scope.item.content)
            $scope.editor.clearSelection()

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
        # TODO: implement change emitter to other viewers
        $scope.editor.on 'change', (e) ->
            $scope.item.content = $scope.editor.getSession().getValue()

            if e.data.range.start.row <= 5 || e.data.range.end.row <= 5
                $scope.item.thumbnail = $scope.getThumbnail()

        # watch changes on coding language and update editor
        $scope.$watch "settings.extension", (option, old_option) ->
            if option.value is ""
                $scope.settings.extension = old_option
                return
            $scope.setEditorExtension( option.value )
            $scope.item.extension = option.extension
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
            return AceSettingsService.font_size
        ), ((font_size) ->
            $scope.settings.font_size = font_size
        ), true

        $scope.$watch (->
            return AceSettingsService.theme
        ), ((theme) ->
            $scope.settings.theme = theme
        ), true

]

app.controller "ScreenshotCtrl", [
    "$scope", "$routeParams", "SharedItemsService", "$modal", "$location"
    ($scope, $routeParams, SharedItemsService, $modal, $location) ->

        $scope.item = {}

        if $routeParams.id?
            $scope.item = SharedItemsService.get($routeParams.id)
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
                SharedItemsService.delete($scope.item.id)
                $location.path("/share")
            )

]

app.controller "ScreenCtrl", [
    "$scope", "$routeParams", "SharedItemsService", "$location", "$filter",
    "$modal", "StreamService"
    ($scope, $routeParams, SharedItemsService, $location, $filter
        $modal, StreamService) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharedItemsService.create("screen")

        else
            $scope.item = SharedItemsService.get($routeParams.id)
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
                $location.path("/share")
            )
]

app.controller "WebcamCtrl", [
    "$scope", "$routeParams", "SharedItemsService", "$location", "$filter",
    "$modal", "StreamService"
    ($scope, $routeParams, SharedItemsService, $location, $filter
        $modal, StreamService) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharedItemsService.create("webcam")

        else
            $scope.item = SharedItemsService.get($routeParams.id)
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
                $location.path("/share")
            )
]

# ***
# * <h3>Chat Controller</h3>
# >
app.controller "ChatCtrl", [
    "$scope", "ChatStateService", "ChatService"
    ($scope, ChatStateService, ChatService) ->
        window.chat = ChatService
        $scope.chat = {}
        $scope.chat.state = ChatStateService.chat_state
        $scope.chat.state_history = ChatStateService.chat_state_history

        $scope.chat.messages = ChatService.messages

        # $scope.$watch ->
        #     ChatService.messages
        # , (value) ->
        #     $scope.chat.messages = value
        # , true
        ###
        $scope.chat.messages = [
            # dummy entries
            {
                sender: "Lorem Ipsum",
                content: "Lorem ipsum dolor sit amet, consetetur sadipscing el"+
                "itr, sed diam nonumy eirmod tempor invidunt ut labore et dolo"+
                "re magna aliquyam erat, sed diam voluptua. At vero eos et acc"+
                "usam et justo duo dolores et ea rebum. Stet clita kasd guberg"+
                "ren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
            }
            {
                sender: "Lorem Ipsum",
                content: "Lorem ipsum dolor sit amet, consetetur sadipscing el"+
                "itr, sed diam nonumy eirmod tempor invidunt ut labore et dolo"+
                "re magna aliquyam erat, sed diam voluptua."
            }
            {
                sender: "Lorem Ipsum",
                content: "Lorem ipsum dolor sit amet, consetetur sadipscing el"+
                "itr, sed diam nonumy eirmod tempor invidunt ut labore et dolo"+
                "re magna aliquyam erat, sed diam voluptua. At vero eos et acc"+
                "usam et justo duo dolores et ea rebum."
            }

        ]
        ###

        $scope.submitChatMessage = ->
            #$scope.chat.messages.push
            #    sender: "Lorem Ipsum"
            #    content: $scope.chat.message
            ChatService.sendMessage $scope.chat.message
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
        id: 1
        category: "screenshot"
        name: "Sophia"
        size: 1036463
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        thumbnail: "images/screenshot.png"
        path: "/images/screenshot.png"
        templateUrl: "/partials/items/thumbnails/screenshot.html"
    }
    {
        id: 2,
        name: "Steffen"
        size: 43696
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        uploaded: "14.05.2014-15:10"
        category: "file"
        thumbnail: "icon"
        path: "/future/path/to/file"
        extension: ".pdf"
        templateUrl: "/partials/items/thumbnails/file.html"
    }
    {
        id: 3,
        name: "style"
        size: 876432
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: ".newspaper {\n" +
            "    -webkit-column-count:3; /* Chrome, Safari, " +
                "Opera */"
        content: '.newspaper {\n' +
            '\t-webkit-column-count:3; /* Chrome, Safari, Opera */\n' +
            '\t-moz-column-count:3; /* Firefox */\n' +
            '\tcolumn-count:3;\n' +
            '\n\n' +
            '\t-webkit-column-gap:40px; /* Chrome, Safari, Opera */\n' +
            '\t-moz-column-gap:40px; /* Firefox */\n' +
            '\tcolumn-gap:40px;\n' +
            '\n\n' +
            '\t-webkit-column-rule:4px outset #ff00ff; /* Chrome, Safari, Ope' +
                'ra */\n' +
            '\t-moz-column-rule:4px outset #ff00ff; /* Firefox */\n' +
            '\tcolumn-rule:4px outset #ff00ff;\n' +
            '}'
        path: "/future/path/to/file"
        extension: "css"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 4,
        name: "HelloWorld"
        size: 346432
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "import java.io.IOException\n" +
            "import java.util.Map\n\n" +
            "public class MyFirstJavaProgram {\n\n" +
            "     public static void main(String[] args){\n"

        content: 'import java.io.IOException\n' +
            'import java.util.Map\n\n' +
            'public class MyFirstJavaProgram {\n\n' +
                '\tpublic static void main(String[] args) {\n' +
                   '\t\tSystem.out.println("Hello World");\n' +
                '\t}\n' +
            '}\n'
        path: "/future/path/to/file"
        extension: "java"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 5,
        name: "main"
        size: 832
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "var x = myFunction(4, 3) // Function is called,\n\n" +
            "function myFunction(a, b) {\n" +
            "    return a * b; // Fucntion returns the " +
            "product of a and b \n" +
            "}"
        content: 'var x = myFunction(4, 3); // Function is called, return val' +
            'ue will end up in x\n\n' +
            'function myFunction(a, b) {\n' +
            '\treturn a * b; // Function returns the product of a and b\n' +
            '}'
        path: "/future/path/to/file"
        extension: "js"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 6,
        name: "index"
        size: 876432
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "<!doctype html>\n     <html " +
            "lang=\"en\">"
        content:
            '!doctype html>\n' +
                '<html lang="en">\n' +
                    '\t<head>\n' +
                        '\t\t<meta charset="utf-8">\n' +
                        '\t\t<title>The HTML5 Herald</title>\n' +
                        '\t\t<meta name="description" content="The HTML5 Heral'+
                            'd">\n' +
                        '\t\t<meta name="author" content="SitePoint">\n' +
                        '\t\t<link rel="stylesheet" href="css/styles.css?v=1.0'+
                            '">\n' +
                    '\t</head>\n' +
                    '\t<body>\n' +
                        '\t\t<script src="js/scripts.js"></script>\n' +
                    '\t</body>\n' +
                '</html>\n'
        path: "/future/path/to/file"
        extension: "html"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 7,
        name: "script"
        size: 1024
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "testparents, babies = (1, 1)\n" +
            "while babies < 100:\n" +
            "     print 'This generation has {0} babies'." +
            "format(babies)\n" +
            "     parents, babies = (babies, parents + " +
            "babies)'\n"
        content: "parents, babies = (1, 1)\n\n" +
            "while babies < 100:\n" +
            "\tprint 'This generation has {0} babies'.format(babies)\n" +
            "\tparents, babies = (babies, parents + babies)'\n"
        path: "/future/path/to/file"
        extension: "py"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 8,
        name: "spec"
        size: 90123
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "for j in 1..5 do\n" +
            "     for i in 1..5 do\n" +
            "         print i, \" \"\n" +
            "         break if i == 2\n" +
            "     end\n" +
            "end"
        content: 'for j in 1..5 do\n' +
            '\tfor i in 1..5 do\n' +
            '\t\tprint i,  " "\n' +
            '\t\tbreak if i == 2\n' +
            '\tend\n' +
            'end'
        path: "/future/path/to/file"
        extension: "rb"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 9,
        name: "Protocol"
        size: 90123
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "note"
        thumbnail:
            title: "Protocol",
            content: "<p>Loremipsumdolorsitamet, consetetursadipscingelitr, "+
                "seddiamnonumyeirmod.</p><p>temporinvidun tutlaboreet dolorem "+
                "agnaaliquy amerat, seddiamvoluptua.</p>"
        content: "<p>Loremipsumdolorsitamet, consetetursadipscingelitr, "+
            "seddiamnonumyeirmod.</p><p>temporinvidun tutlaboreet dolorem "+
            "agnaaliquy amerat, seddiamvoluptua.</p>"
        path: "/future/path/to/file"
        last_edited: "20.05.2014-20:25"
        templateUrl: "/partials/items/thumbnails/note.html"
    }
    {
        id: 10,
        name: "How to photoshop"
        size: 0
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "screen"
        thumbnail: "screenshot-screen.png"
        templateUrl: "/partials/items/thumbnails/screen.html"
    }
    {
        id: 11,
        name: "See me cooking"
        size: 0
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "webcam"
        thumbnail: "screenshot-webcam.jpg"
        templateUrl: "/partials/items/thumbnails/webcam.html"
    }
    {
        id: 12,
        name: "Cute Cat Picture"
        size: 190123
        author: "Hermine"
        thumbnail: "images/image.jpg"
        created: "14.05.2014-15:10"
        uploaded: "14.05.2014-15:15"
        category: "image"
        path: "/images/image.jpg"
        templateUrl: "/partials/items/thumbnails/image.html"
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