# Unwatched - Stream Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives"

app.directive "stream", [
    "SharesService", "$rootScope"
    (SharesService, $rootScope) ->
        restrict: 'A'
        link: (scope, element, attrs) ->
            console.log "stream with attrs", attrs
            scope.$watch ->
                SharesService.shares
            , (shares) ->
                console.log "change on shares", shares
                if $rootScope.isStreaming[attrs.stream]
                    console.log "already sharing " + attrs.stream + "; return;"
                    return
                for share in shares
                    console.log "share author is", share.author
                    console.log "share user is", $rootScope.userId
                    if share.author isnt $rootScope.userId
                        continue
                    console.log "share category is", share.category
                    console.log "share attrs is", attrs.stream
                    if share.category isnt attrs.stream
                        continue

                    console.log "share.content is", share.content
                    if share.content? and share.content isnt ''
                        console.log "stream detected"
                        console.log "start sharing " + attrs.stream
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
                console.log "click with attrs", attrs
                SharesService.delete $rootScope.streamId[attrs.killStream]
                $rootScope.isStreaming[attrs.killStream] = false
                $rootScope.streamId[attrs.killStream] = -1
                angular.element("#" + attrs.killStream).src = null
                console.log $location.path()
                $location.path("/share") if $location.path() is "/share/stream"
                $rootScope.$apply() if !$rootScope.$$phase

]
