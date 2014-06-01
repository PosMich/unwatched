# # Unwatched - Clipboard Directive
# # ==============================
#
# "use strict"
#
# app = angular.module "unwatched.directives"
#
# app.directive "copyClipboard", [
#     "SharesService",
#     (SharesService) ->
#         restrict: "A"
#         link: (scope, element, attrs) ->
#           clip = new ZeroClipboard element
#
#           clip.on "load", (client) ->
#               onDataRequested = (client) ->
#                   client.setText "test"
#
#
#           client.on "dataRequested", onDataRequested
#
#
#           if (attrs.clipCopy == "") {
#             scope.clipCopy = function(scope) {
#               return element[0].previousElementSibling.innerText;
#             };
#           }
#           clip.on( 'load', function(client) {
#             var onDataRequested = function (client) {
#               client.setText(scope.$eval(scope.clipCopy));
#               if (angular.isDefined(attrs.clipClick)) {
#                 scope.$apply(scope.clipClick);
#               }
#             };
#             client.on('dataRequested', onDataRequested);
#
#             scope.$on('$destroy', function() {
#               client.off('dataRequested', onDataRequested);
#               client.unclip(element);
#             });
# ]
