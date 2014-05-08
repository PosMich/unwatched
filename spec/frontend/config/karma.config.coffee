# Karma configuration
# Generated on Mon Jan 20 2014 17:57:25 GMT+0100 (CET)

module.exports = (config) ->
  config.set

    # base path, that will be used to resolve all patterns, eg. files, exclude
    basePath: "../../../"

    # frameworks to use
    frameworks: ["jasmine"]

    # preprocessors
    preprocessors: 
        "**/*.coffee": ["coffee"]

    # list of files / patterns to load in the browser
    files: [
      "public/js/app.js"
      "spec/frontend/unit/**/*.*"
    ]

    # list of files to exclude
    exclude: [
      "assets/js/lib/angular-scenario.js",
    ]

    # test results reporter to use
    # possible values: "dots", "progress", "junit", "growl", "coverage"
    reporters: ["progress"]

    # web server port
    port: 9876

    # enable / disable colors in the output (reporters and logs)
    colors: true

    # level of logging
    # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO

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
    browsers: ["PhantomJS"]

    # If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: true
