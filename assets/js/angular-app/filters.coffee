# Unwatched - Angular Filters
# ===========================

"use strict"

app = angular.module("unwatched.filters", [])

# ***
# * <h3>iif</h3>
# > Filter for immediate if - aka iif
# > Frontend-usage: {{confition | iif : "it's true" : "it's false"}}
app.filter "iif", [ ->
    (input, trueValue, falseValue) ->
        (if input then trueValue else falseValue)
]

app.filter "interpolate", [
    "version"
    (version) ->
        (text) ->
            String(text).replace /\%VERSION\%/g, version
]

app.filter "humanReadableFileSize", ->
    (bytes) ->
        return 0  if bytes <= 0
        s = [
            "bytes"
            "kB"
            "MB"
            "GB"
            "TB"
            "PB"
        ]
        e = Math.floor(Math.log(bytes) / Math.log(1024))
        (bytes / Math.pow(1024, Math.floor(e))).toFixed(2) + " " + s[e]

app.filter "breakFilter", ->
    (text) ->
        text.replace(/\n/g, '<br />') if text?

app.filter "noHtml", ->
    (text) ->
        if text?
            text.replace(/&/g, '&amp;').replace(/>/g, '&gt;')
                .replace(/</g, '&lt;')

app.filter "shorten", ->
    (text) ->
        text.substr(0, 25) + "..."
