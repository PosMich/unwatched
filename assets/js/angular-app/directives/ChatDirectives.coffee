# Unwatched - Chat Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives"

# * <h3>chat</h3>
# > Loads the template for a chat window

app.directive "chat", [ ->
    templateUrl: "/partials/chat.html"
]

# ***
# * <h3>UpdateScrollPosition</h3>
# > Scrolls the container view to the bottom if new child-elements appear<br/>
# > Frontend-usage: div(update-scroll-position="containerElementId")<br/>
# > Additional note: window.setTimeout-Workaround - the directives is triggered
# > by an update on the model. To get the right height of the container element
# > we need to wait 1ms until the view is up-to-date - this is just a workaround
# > and needs optimization
app.directive "updateScrollPosition", [
    "$window", "ChatStateService"
    ($window, ChatStateService) ->
        link: (scope, elem, attrs) ->

            scope.$watch attrs.updateScrollPosition, ->
                window.setTimeout((->
                    elem.scrollTop elem.find("> div").height()
                ), 0)

            angular.element($window).bind "resize", ->
                window.setTimeout((->
                    elem.scrollTop elem.find("> div").height()
                ), 0)

            scope.$watch ->
                ChatStateService.chat_state
            , ->
                window.setTimeout((->
                    elem.scrollTop elem.find("> div").height()
                ), 0)

            window.setTimeout((->
                elem.scrollTop elem.find("> div").height()
            ), 0)
]

# ***
# * <h3>focusOnClick</h3>
# > Sets the focus on a certain input field after a click event was fired.<br/>
# > Frontend-usage: a(focus-on-click="fieldToBeFocusedId")
app.directive "focusOnClick", [ ->
    link: (scope, elem, attrs) ->
        focusField = "#" + attrs.focusOnClick
        elem.on "click", ->
            $(focusField).focus()
            return
        return
]

app.directive "fitWindowHeight", [
    "$window"
    ($window) ->
        link: (scope, element, attrs) ->

            wElement = angular.element($window)

            scope.getElementDimensions = ->
                { 'height': wElement.height() }

            scope.$watch ->
                scope.getElementDimensions()
            , (dimensions) ->
                console.log dimensions
                element.height dimensions.height
            , true

            wElement.bind "resize", ->
                scope.$apply() if !scope.$$phase
]

app.directive "rearangeContainer", [
    "$window", "$location"
    ($window, $location) ->
        link: (scope, elem, attrs) ->

            rearange = (elem, attrs) ->
                $container = $(".view-frame")

                if scope.chat.state is "expanded"
                    $container.addClass("chat-expanded")
                    $container.removeClass("chat-compressed")
                else
                    $container.addClass("chat-compressed")
                    $container.removeClass("chat-expanded")


            scope.$watch attrs.rearangeContainer, ->
                rearange()

            scope.$location = $location
            scope.$watch "$location.path()", ->
                window.setTimeout((->
                    rearange()
                ), 500)

            rearange()

]
