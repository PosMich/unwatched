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
        console.log "asdf"
        ctrl.$setValidity "inputMatch", v
        return
      return
    return
]

# ***
# * <h3>client</h3>
# > Loads the template for a single client (/partials/client.jade)
# > and adds a watcher to keep the dimensions 1:1 <br/>
# > Frontend-usage: div(client)

app.directive "client", [
  "$window"
  ($window) ->
    templateUrl: "/partials/client.jade"
    link: (scope, elem) ->
      w = angular.element($window)
      elem.height elem.width()
      $(elem).find(".client-options span i").css("line-height",
        (elem.width() / 2) + "px")
      w.bind "resize", ->
        elem.height elem.width()
        $(elem).find(".client-options span i").css("line-height",
          (elem.width() / 2) + "px")
        return
      return
]

# ***
# * <h3>UpdateScrollPosition</h3>
# > Scrolls the container view to the bottom if new child-elements appear<br/>
# > Frontend-usage: div(update-scroll-position="containerElementId")<br/>
# > Additional note: window.setTimeout-Workaround - the directives is triggered
# > by an update on the model. To get the right height of the container element
# > we need to wait 1ms until the view is up-to-date - this is just a workaround
# > and needs optimization
app.directive "updateScrollPosition", [ ->
  link: (scope, elem, attrs) ->
    scope.$watch attrs.updateScrollPosition, ->
      window.setTimeout( (-> $(elem).parent().scrollTop $(elem).height()), 1 )
]

# ***
# * <h3>adjustWidth</h3>
# > Is used on the tab-directive. Similar to the attribute "justified", but
# > sets a definite width on each tab. (value = containerWidth / n)<br/>
# > Adjusts width on init, on change of the given attr and on window resize<br/>
# > Frontend-usage: tabset(adjust-width="attr")<br/>
# > Additional note: window.setTimeout-Workaround, as mentioned above
app.directive "adjustWidth", [
  "$window"
  ($window) ->
    link: (scope, elem, attrs) ->

      adjustElementWidth = (elem, attrs) ->
        adjustedWidth = $(elem).find("ul").width()
        elems = $(elem).find( "ul li" ).length
        adjustedWidth = ((adjustedWidth / elems) - 2)  if elems > 0
        $(elem).find("ul li a").css( "width",  adjustedWidth)
        return

      scope.$watch attrs.adjustWidth, ->
        window.setTimeout( (->
          adjustElementWidth(elem, attrs)
        ), 1)

      angular.element($window).bind "resize", ->
        adjustElementWidth(elem, attrs)
        return
]

# ***
# * <h3>delayDisplay</h3>
# > Delays the display of a certain hidden element. Adds the "show" css-class,
# > after the element has been added to the view.<br/>
# > Frontend-usage: div(delay-display="modelOfDelayedElement")<br/>
# > Additional note: Atm it just works with opacity: 0 elements.
app.directive "delayDisplay", [ ->
  link: (scope, elem, attrs) ->
    scope.$watch attrs.delayDisplay, ->
      $(elem).addClass "show"
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
