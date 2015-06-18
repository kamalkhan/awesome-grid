module.exports = (config) ->

    config.set

        # base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '../'


        # frameworks to use
        # available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        frameworks: [
            'jasmine-jquery', 'jasmine'#, 'detectBrowsers'
        ]


        detectBrowsers:
            postDetection: (availableBrowsers) ->
                #Add IE Emulation
                browsers = availableBrowsers;
                if availableBrowsers.indexOf 'IE' > -1
                    browsers.push('IE9')
                #Remove PhantomJS if another browser has been detected
                if availableBrowsers.length > 1 and availableBrowsers.indexOf 'PhantomJS' > -1
                    i = browsers.indexOf 'PhantomJS'
                    if i isnt -1 then browsers.splice i, 1
                browsers



        # list of files / patterns to load in the browser
        files: [
            'build/fixture.html',
            'build/fixture.css',
            'src/awesome-grid.coffee',
            'build/awesome-grid.spec.coffee'
        ]


        # list of files to exclude
        exclude: []


        coffeePreprocessor:
            # options passed to the coffee compiler
            options:
                bare: no,
                sourceMap: no

        # preprocess matching files before serving them to the browser
        # available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
        preprocessors:
            'src/awesome-grid.coffee': ['coffee']
            'build/awesome-grid.spec.coffee': ['coffee']


        # test results reporter to use
        # possible values: 'dots', 'progress'
        # available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['spec']

        notifyReporter:
            reportEachFailure: true # Default: false, Will notify on every failed sepc
            reportSuccess: true # Default: true, Will notify when a suite was successful

        # web server port
        port: 9876

        # enable / disable colors in the output (reporters and logs)
        colors: yes

        # level of logging
        # possible values:
        # - config.LOG_DISABLE
        # - config.LOG_ERROR
        # - config.LOG_WARN
        # - config.LOG_INFO
        # - config.LOG_DEBUG
        logLevel: config.LOG_INFO

        # enable / disable watching file and executing tests whenever any file changes
        autoWatch: yes

        # start these browsers
        # available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        browsers: [
            'PhantomJS',
            #'karma-chrome-launcher',
            #'karma-firefox-launcher',
            #'karma-ie-launcher',
            #'karma-safari-launcher',
            #'karma-opera-launcher',
            #'karma-phantomjs-launcher',
            #'karma-detect-browsers'
        ]

        # Continuous Integration mode
        # if true, Karma captures browsers, runs the tests and exits
        singleRun: no
