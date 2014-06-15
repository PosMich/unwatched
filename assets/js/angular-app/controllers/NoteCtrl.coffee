# Unwatched - Note Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "NoteCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$modal",
    "$filter", "$rootScope", "UserService", "RTCService", "$timeout"
    ($scope, $routeParams, SharesService, $location, $modal
        $filter, $rootScope, UserService, RTCService, $timeout) ->

        $scope.item = {}
        $scope.users = UserService.users
        $scope.user = $scope.users[$rootScope.userId]

        $scope.copiedText = false

        if !$routeParams.id?
            # create new note item
            $scope.item = SharesService.get(
                SharesService.create($rootScope.userId, "note") )

            RTCService.sendNewNoteItem( $scope.item, $scope.user.isMaster )

            $scope.item.locked = $rootScope.userId

            message =
                locked: $rootScope.userId

            RTCService.sendFileHasChanged(message, $scope.item.id, $scope.user)

        else
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

            # push to contributers
            if $scope.item.contributors.indexOf($rootScope.userId) is -1
                $scope.item.contributors.push $rootScope.userId

                message =
                    contributors: $scope.item.contributors

                RTCService.sendFileHasChanged(
                    message
                    $scope.item.id
                    $scope.user
                )


        $scope.blocked = true

        if $scope.item.locked is -1
            $scope.blocked = false
            $scope.item.locked = $rootScope.userId
            message =
                locked: $rootScope.userId

            RTCService.sendFileHasChanged(message, $scope.item.id, $scope.user)

        else if $scope.item.locked is $rootScope.userId
            $scope.blocked = false

        # tinymce options
        $scope.tinymceOptions = {
            resize: "both"
            height: 400
            menubar: false
            setup: (editor) ->
                editor.on "change", (e) ->
            oninit: ->
                #console.log "blocked " + $scope.blocked
                tinymce.activeEditor.getBody().setAttribute(
                    'contenteditable', !$scope.blocked)


        }

        $scope.$watch ->
            $scope.item.locked
        , (value) ->
            if tinymce.activeEditor?
                if value is -1
                    #console.log "enabling editor"
                    tinymce.activeEditor.getBody().setAttribute(
                        'contenteditable', true)
                    $scope.blocked = false

                    $scope.item.locked = $rootScope.userId
                    message =
                        locked: $rootScope.userId

                    RTCService.sendFileHasChanged(
                        message
                        $scope.item.id
                        $scope.user
                    )

                else if value isnt $rootScope.userId
                    #console.log "disabling editor, because "
                    # + value + " is " + $rootScope.userId
                    tinymce.activeEditor.getBody().setAttribute(
                        'contenteditable', false)
                    $scope.blocked = true

        , true

        $scope.$watch ->
            $scope.item.name
        , (value) ->
            if value? and value isnt ""
                message =
                    name: value

                RTCService.sendFileHasChanged(
                    message
                    $scope.item.id
                    $scope.user
                )
        , true


        $scope.save = ->

            $scope.item.last_edited = new Date()
            thumbnail = String($scope.item.content).replace(/<[^>]+>/gm, '')
            thumbnail = thumbnail.substr(0,200) + "..."


            $scope.item.thumbnail = thumbnail

            message =
                content: $scope.item.content
                last_edited: new Date()
                thumbnail: $scope.item.thumbnail

            RTCService.sendFileHasChanged(message, $scope.item.id, $scope.user)
            $scope.success = true

            $timeout(
                ->
                    $scope.success = false
                1500
            )

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

        $scope.getClipText = ->
            $scope.copiedText = true
            $scope.$apply() if !$scope.$$phase
            $timeout(
                ->
                    $scope.copiedText = false
                2500
            )
            return $scope.item.content


        $scope.$on "$routeChangeStart", (scope, next, current) ->

            $scope.item.locked = -1
            message =
                locked: -1

            RTCService.sendFileHasChanged(message, $scope.item.id, $scope.user)


]
