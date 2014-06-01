# Unwatched - Shares Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives"

app.directive "fitItemHeight", [
    "$window", "$timeout", "$location"
    ($window, $timeout, $location) ->
        link: (scope, elem, attrs) ->
            fitHeight = (elem, attrs) ->
                if attrs.fitItemHeight is "layout-icons"
                    $items = $(elem).find(".item-container")
                    width = $items.first().width()

                    for item in $items
                        if $(item).width() < width
                            width = $(item).width()

                    $items.css "height", width / 4 * 3
                    return

            scope.$watch ->
                scope.shared_items
            , (items) ->
                window.setTimeout((->
                    fitHeight(elem, attrs)
                ), 0)
            , true

            scope.$watch ->
                scope.controls.layout
            , (value) ->
                window.setTimeout((->
                    fitHeight(elem, attrs)
                ), 0)

            scope.$watch ->
                scope.controls.searchString
            , ->
                window.setTimeout((->
                    fitHeight(elem, attrs)
                ), 0)

            scope.$watch ->
                scope.chat_state
            , (value) ->
                window.setTimeout((->
                    fitHeight(elem, attrs)
                ), 0)

            angular.element($window).bind "resize", ->
                fitHeight(elem, attrs)

            scope.$location = $location
            scope.$watch "$location.path()", ->
                if $location.path() is "/share"
                    window.setTimeout((->
                        fitHeight(elem, attrs)
                    ), 500)

            window.setTimeout((->
                fitHeight(elem, attrs)
            ), 0)

]

app.directive "resizable", [
    "ChatStateService"
    (ChatStateService) ->
        restrict: "A"
        scope:
            callback: "&onResize"

        link: (scope, elem, attrs) ->

            resizeConfig = {
                maxHeight: 600
                minHeight: 200
                maxWidth: elem.parent().width()
                minWidth: 200
            }

            elem.resizable resizeConfig
            elem.on "resizestop", (evt, ui) ->
                scope.callback()  if scope.callback

]

app.directive "resizeDetailView", [
    "ChatStateService"
    (ChatStateService) ->
        link: (scope, elem, attrs) ->

            scope.$watch ->
                ChatStateService.chat_state
            , (state) ->
                window.setTimeout(( ->
                    width = elem.parent().width()
                    if elem.width() > width
                        elem.width width
                    else if state is 'expanded'
                        elem.width '100%'
                    else if state isnt 'expanded'
                        elem.width '60%'
                ), 0)

]
