# # Dependencies
# ## [xxx](http://xxx.com/)

# ## [jQuery](http://jquery.com/download/)
#= require lib/jquery-2.0.3.js
# ## [Bootstrap](http://getbootstrap.com/)
#= require lib/bootstrap.js
# ## [AngularJS](http://angularjs.org/)
#= require lib/angular.js
#= require lib/angular-route.js

# # Here we go!

# ***
# `$ ->` is a shorthand for `$( document ).ready( function() { ... });`

angular.module "app", ["ngRoute"]

$ ->
