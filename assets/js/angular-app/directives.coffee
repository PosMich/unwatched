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
# > Loads the template for a single member (/partials/member.jade)
# > and adds a watcher to keep the dimensions 1:1 <br/>
# > Frontend-usage: div(member)

app.directive "member", [
  "$window"
  ($window) ->
    templateUrl: "/partials/member.jade"
    link: (scope, elem) ->
      # w = angular.element($window)
      # elem.height elem.width()
      # $(elem).find(".member-options span i").css("line-height",
        # (elem.width() / 2) + "px")
      # w.bind "resize", ->
      #   elem.height elem.width()
      #   $(elem).find(".member-options span i").css("line-height",
      #     (elem.width() / 2) + "px")
      #   return
      # return
]

# ***
# * <h3>chat</h3>
# > Loads the template for a chat window

app.directive "chat", [ ->
    templateUrl: "/partials/chat.jade"
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
    "$window"
    ($window) ->
        link: (scope, elem, attrs) ->
            scope.$watch attrs.updateScrollPosition, ->
                window.setTimeout( (-> $(elem).parent().scrollTop $(elem).height()), 1 )

            angular.element($window).bind "resize", ->
                $(elem).parent().scrollTop $(elem).height()

            window.setTimeout( (-> $(elem).parent().scrollTop $(elem).height()), 1 )
]

# ***
# * <h3>adjustWidth</h3>
# > Is used on the tab-directive. Similar to the attribute "justified", but
# > sets a definite width on each tab. (value = containerWidth / n)<br/>
# > Adjusts width on init, on change of the given attr and on window resize<br/>
# > Frontend-usage: tabset(adjust-width="attr")<br/>
# > Additional note: window.setTimeout-Workaround, as mentioned above
# app.directive "adjustWidth", [
#     "$window"
#     ($window) ->
#     link: (scope, elem, attrs) ->

#       adjustElementWidth = (elem, attrs) ->
#         adjustedWidth = $(elem).find("ul").width()
#         elems = $(elem).find( "ul li" ).length
#         adjustedWidth = ((adjustedWidth / elems) - 2)  if elems > 0
#         $(elem).find("ul li a").css( "width",  adjustedWidth)
#         return

#       scope.$watch attrs.adjustWidth, ->
#         window.setTimeout( (->
#           adjustElementWidth(elem, attrs)
#         ), 1)

#       angular.element($window).bind "resize", ->
#         adjustElementWidth(elem, attrs)
#         return
# ]

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


app.directive "appVersion", [
  "version"
  (version) ->
    (scope, elem, attrs) ->
      elem.text version
]

app.directive "centerVertical", [
    "$window"
    ($window) ->
      link: (scope, elem, attrs) ->

        centerVertical = (elem, attrs) ->
            marginTop = ( $($window).height()-$(elem).height() )/2
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

app.directive "absoluteFillRelativeFullHeight", [
    "$window"
    ($window) ->
      link: (scope, elem, attrs) ->

        fillHeight = (elem, attrs) ->
            if scope.chat.state is "minimized"
                $heading = $(elem).find(".panel-heading")
                console.log($heading.css("padding-top").replace(/[^-\d\.]/g, ''))
                console.log($heading.height())

                height = $heading.height() + parseInt($heading
                    .css("padding-top").replace(/[^-\d\.]/g, ''))*2

                console.log height

                width = $(elem).parent().width() / 2
            else
                divider = 1
                if scope.chat.state is "compressed"
                  divider = 2

                height = $($window).height() / divider
                width = $(elem).parent().width() / divider

            $(elem).css "height", height
            $(elem).css "width", width
            return

        scope.$watch attrs.absoluteFillRelativeFullHeight, ->
          window.setTimeout( (->
            fillHeight(elem, attrs)
          ), 1)

        angular.element($window).bind "resize", ->
          fillHeight(elem, attrs)
          return
]

app.directive "fitChatBodyHeight", [
    "$window"
    ($window) ->
      link: (scope, elem, attrs) ->

        fitHeight = (elem, attrs) ->
            divider = 1
            if scope.chat.state is "compressed"
              divider = 2

            $parent = $(elem).parent()
            $heading = $parent.find(".panel-heading")
            $footer = $parent.find(".panel-footer")

            heading_padding = $heading.css("padding-top").replace(/[^-\d\.]/g, '')
            footer_padding = $heading.css("padding-top").replace(/[^-\d\.]/g, '')

            height = ($($window).height()/divider)-30 - $heading.height() - 
              $footer.height()
            
            $(elem).css "height", height
            return

        scope.$watch attrs.fitChatBodyHeight, ->
          window.setTimeout( (->
            fitHeight(elem, attrs)
            $container = $(elem).find(".message-container")
            $(elem).scrollTop $container.height()
          ), 10)

        angular.element($window).bind "resize", ->
          fitHeight(elem, attrs)
          return
]
