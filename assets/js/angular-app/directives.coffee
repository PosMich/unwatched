# Unwatched - Angular Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives", []

# ***
# * <h3>inputMatch</h3>
# > Directive to validate wheter two inputs are equal <br/>
# > Frontend-usage: input(input-match="origin-input-field-id")

app.directive "inputMatch", [ ->
  require: "ngModel"
  link: (scope, elem, attrs, ctrl) ->
    originInput = "#" + attrs.inputMatch
    elem.add(originInput).on "input", ->
      scope.$apply ->
        v = elem.val() is $(originInput).val()
        ctrl.$setValidity "inputMatch", v
        return
      return
    return
]

# ***
# * <h3>member</h3>
# > Loads the template for a single member (/partials/member.html)
# > and adds a watcher to keep the dimensions 1:1 <br/>
# > Frontend-usage: div(member)

app.directive "member", [ ->
    templateUrl: "/partials/member.html"
]

# ***
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
                  $(elem).scrollTop $(elem).find("> div").height()
                ), 0)

            angular.element($window).bind "resize", ->
                window.setTimeout((->
                    $(elem).scrollTop $(elem).find("> div").height()
                ), 0)

            scope.$watch ->
                ChatStateService.chat_state
            , () ->
                window.setTimeout((->
                     $(elem).scrollTop $(elem).find("> div").height()
                ), 0)

            window.setTimeout((->
              $(elem).scrollTop $(elem).find("> div").height()
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

app.directive "centerVertical", [
    "$window"
    ($window) ->
      link: (scope, elem, attrs) ->

        centerVertical = (elem, attrs) ->
            marginTop = ( $($window).height() - $(elem).height() ) / 2
            $(elem).css "margin-top", marginTop
            return

        scope.$watch attrs.adjustWidth, ->
          window.setTimeout( (->
            centerVertical(elem, attrs)
          ), 1)

        angular.element($window).bind "resize", ->
          centerVertical(elem, attrs)
          return
]



app.directive "appVersion", [
  "version"
  (version) ->
    (scope, elem, attrs) ->
      elem.text version
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
        scope.$watch('$location.path()', ->
          window.setTimeout((->
            rearange()
          ), 500)
        )

        rearange()

]

app.directive "fitItemHeight", [
    "$window", "$timeout"
    ($window, $timeout) ->
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
            scope.controls.layout
        , (value) ->
            window.setTimeout((->
                fitHeight(elem, attrs)
            ), 0)

        scope.$watch ->
            scope.controls.searchString
        , () ->
            window.setTimeout((->
                fitHeight(elem, attrs)
            ), 0)
          
        angular.element($window).bind "resize", ->
          fitHeight(elem, attrs)

        window.setTimeout((->
          fitHeight(elem, attrs)
        ), 0)

]
