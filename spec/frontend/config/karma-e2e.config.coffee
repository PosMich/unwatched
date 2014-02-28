# Karma configuration
# Generated on Mon Jan 20 2014 17:57:25 GMT+0100 (CET)

userConfig = require "../../../modules/config"

module.exports = (config) ->
  config.set

    # base path, that will be used to resolve all patterns, eg. files, exclude
    basePath: '../'

    # changing the urlRoot from '/' is necessary because the testing server
    # 'testacular' occupies the same url root as the real unwatched app due
    # the same origin policy - otherwise we wouldn't be able to test the root
    # page of unwatched
    urlRoot: '/__testacular/'

    # list of files / patterns to load in the browser
    files: [
      'e2e/*.coffee'
    ]

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: false

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera (has to be installed with `npm install karma-opera-launcher`)
    # - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    # - PhantomJS
    # - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['PhantomJS']

    # frameworks to use
    frameworks: ['ng-scenario']

    singleRun: true

    proxies:
      '/': 'http://localhost:#{userConfig.port}/'

    plugins: [
      'karma-phantomjs-launcher',
      'karma-jasmine',
      'karma-ng-scenario'
      'karma-coffee-preprocessor'
    ]
