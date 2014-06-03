# Unwatched - File Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "FileCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$modal",
    "UserService", "$rootScope", "RTCService", "FileService"
    ($scope, $routeParams, SharesService, $location, $modal, UserService,
        $rootScope, RTCService, FileService) ->

        $scope.users = UserService.users
        $scope.user = $scope.users[$rootScope.userId]

        if !$routeParams.id?
            # create new image item

            $scope.file = {}
            $scope.item = {}
            $scope.item.size = 0
            $scope.item.name = "Untitled"
            $scope.newFile = true




            $scope.onFileSelect = ($files) ->
                sharedItemId = SharesService.create( $rootScope.userId, "file" )
                $scope.item = SharesService.get( sharedItemId )
                $scope.item.mime_type = ""


                RTCService.sendNewFile( $scope.item, $scope.user.isMaster )

                $scope.file.source = $files[0]

                $scope.item.name = $scope.file.source.name
                $scope.item.mime_type = $scope.file.source.type
                $scope.item.size = $scope.file.source.size
                $scope.item.created = $scope.file.source.lastModifiedDate
                $scope.item.uploaded = new Date()

                if $scope.item.size < 30000000
                    $scope.file.progress = 100

                if (/image\/(gif|jpeg|png)$/i).test($scope.file.source.type.toString())
                    $scope.item.category = "image"

                # read file
                reader = new FileReader()

                reader.onload = (e) ->

                    if $scope.item.category is "image"
                        $scope.target_result = e.target.result

                    window.setTimeout(->
                        $scope.file.show_progress = false
                        $scope.file.ready = true
                        $scope.$apply()
                    , 2000)

                    FileService.createFile( $scope.item.id, $scope.file.source )

                reader.onprogress = (e) ->
                    console.log "progress"
                    $scope.file.show_progress = true
                    $scope.$apply()
                    percentLoaded = Math.round((e.loaded / e.total) * 100)
                    $scope.file.progress = percentLoaded

                reader.readAsDataURL $scope.file.source

            $scope.$watch ->
                $scope.file.ready
            , (ready) ->
                if ready
                    $scope.item.content = $scope.target_result

                    img = document.createElement("img")
                    canvas = document.createElement("canvas")

                    if $scope.item.category is "image"
                        img.src = $scope.target_result
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

                            $scope.$apply() if !$scope.$$phase
            , true

            $scope.$watch ->
                $scope.item.thumbnail
            , (thumbnail) ->
                if thumbnail? and thumbnail.length isnt 0
                    # send file changes
                    fileMessage =
                        category: $scope.item.category
                        size: $scope.item.size
                        created: $scope.item.created
                        uploaded: $scope.item.uploaded
                        mime_type: $scope.item.mime_type
                        thumbnail: $scope.item.thumbnail

                    if $scope.item.size < (1024*1024*2)
                        fileMessage.content = $scope.item.content

                    RTCService.sendFileHasChanged(fileMessage,
                        $scope.item.id, $scope.user)

                    $location.path("/share/file/" + $scope.item.id)
                    $rootScope.$apply() if !$rootScope.$$phase

            , true


        else
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?
            $scope.newFile = false

            # create file from item.content
            if $scope.item.content? and $scope.item.content.length isnt 0
                console.log $scope.item.content

                byteString = atob($scope.item.content.split(',')[1])
                ab = new ArrayBuffer byteString.length
                ia = new Uint8Array ab

                for i of byteString
                    ia[i] = byteString.charCodeAt i

                console.log "uint8array is", ia

                $scope.file_source = ia

        $scope.$watch ->
            $scope.item.name
        , (name) ->
            fileMessage =
                name: name
            RTCService.sendFileHasChanged(fileMessage, $scope.item.id,
                $scope.user)
        , true


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
                RTCService.sendItemDeleted( $scope.user, $scope.item.id )
                SharesService.delete $scope.item.id
                $location.path "/share"
            )
]
