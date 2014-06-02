# Unwatched - Stream Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives"

app.directive "stream", [
    "SharesService"
    "RTCService"
    "$rootScope"
    "UserService"
    (SharesService, RTCService, $rootScope, UserService) ->
        restrict: 'A'
        link: (scope, element, attrs) ->
            scope.$watch ->
                SharesService.shares
            , (shares) ->
                if $rootScope.isStreaming[attrs.stream]
                    return
                for share in shares
                    if share.author isnt $rootScope.userId
                        continue
                    if share.category isnt attrs.stream
                        continue

                    if share.content? and share.content isnt ''
                        element[0].src =
                            window.URL.createObjectURL share.content
                        element[0].play()
                        $rootScope.isStreaming[attrs.stream] = true
                        $rootScope.streamId[attrs.stream] = share.id
            , true

]

app.directive "killStream", [
    "SharesService"
    "$rootScope"
    "$location"
    (SharesService, $rootScope, $location) ->
        restrict: 'A'
        link: (scope, element, attrs) ->

            element.on "click", ->
                SharesService.delete $rootScope.streamId[attrs.killStream]
                $rootScope.isStreaming[attrs.killStream] = false
                $rootScope.streamId[attrs.killStream] = -1
                angular.element("#" + attrs.killStream).src = null
                if $location.path().indexOf("/share/stream") isnt -1
                    $location.path("/share")
                $rootScope.$apply() if !$rootScope.$$phase

]

app.directive "showStream", [
    "SharesService"
    "UserService"
    "RTCService"
    "$rootScope"
    "$location"
    (SharesService, UserService, RTCService, $rootScope, $location) ->
        restrict: 'A'
        link: (scope, element, attrs) ->

            scope.$watch ->
                scope.item
            , (item) ->
                if item.content? and item.content isnt ""
                    element[0].src =
                        window.URL.createObjectURL item.content
                    element[0].play()
            , true

            element.on "click", ->
                canvas = document.createElement("canvas")
                canvas_thumbnail = document.createElement("canvas")

                console.log element.width()
                console.log element.height()

                console.log element
                canvas.width = element.width()
                canvas.height = element.height()

                ctx = canvas.getContext("2d")
                ctx.drawImage(element[0], 0, 0)

                author = UserService.getUser scope.item.author
                user = UserService.getUser $rootScope.userId

                screenshotId =
                    SharesService.create($rootScope.userId, "screenshot")
                screenshot = SharesService.get screenshotId
                screenshot.content = canvas.toDataURL("image/png")
                screenshot.mime_type = "image/png"

                screenshot.name = "Screenshot\: " + scope.item.category + " of " +
                    author.name

                # create thumbnail
                max_width = 300
                width = element.width()
                height = element.height()

                if width > max_width
                    height *= max_width / width
                    width = max_width

                canvas_thumbnail.width = width
                canvas_thumbnail.height = height

                console.log "canvas is", canvas
                ctx_thumbnail = canvas_thumbnail.getContext "2d"
                ctx_thumbnail.drawImage( canvas, 0, 0, width, height )

                thumbnailDataUrl = canvas_thumbnail.toDataURL("image/png")
                scope.item.thumbnail = thumbnailDataUrl
                screenshot.thumbnail = thumbnailDataUrl


                RTCService.sendNewFile(screenshot, user.isMaster)

                updates =
                    thumbnail: scope.item.thumbnail

                RTCService.sendFileHasChanged(updates, scope.item.id, user)


                $location.path("/share/file/" + screenshotId)
                $rootScope.$apply() if !$rootScope.$$phase



]
