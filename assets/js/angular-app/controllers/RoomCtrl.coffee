# Unwatched - Room Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "RoomCtrl", [
    "$scope", "RoomService", "UserService", "SharesService",
    "ChatStateService", "$routeParams", "RTCService", "$rootScope",
    "$location", "FileApiService"
    ($scope, RoomService, UserService, SharesService,
        ChatStateService, $routeParams, RTCService, $rootScope,
        $location, FileApiService) ->

        $scope.isInRoom = RoomService.id isnt ""
        if !$scope.isInRoom
            return
        #console.log "blubb"
        $scope.room = RoomService
        $scope.room.users = UserService.users

        $scope.user = UserService.getUser( $rootScope.userId )

        if !$scope.user
            $location.path "/"

        $scope.user.borderColor = $scope.user.getColorAsRGB()

        $scope.chat_state = ChatStateService.chat_state

        $scope.$watch ->
            ChatStateService.chat_state
        , (new_state, old_state) ->
            $scope.chat_state = new_state
        , true



        # room infos
        $scope.usersLength = 0
        $scope.room.files = SharesService.shares

        $scope.$watch ->
            UserService.users
        , (users) ->
            $scope.usersLength = 0
            for user in users
                if user.isActive
                    $scope.usersLength++
        , true

        # init fs
        FileApiService.initFs()

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
                    #console.log "processing image: " + coord_x + ", " + coord_y
                    #console.log "source boundaries: " + img_width +
                    #    ", " + img_height

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

]
