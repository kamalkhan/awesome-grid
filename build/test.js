var gulp   = require('gulp');
var karma  = require('karma').server;

gulp.task('test', function (done) {
    karma.start({
        configFile: __dirname + '/karma.conf.coffee',
        singleRun: true
    }, function(){ done(); });
});

gulp.task('test-watch', function (done) {
    karma.start({
        configFile: __dirname + '/karma.conf.coffee'
    }, function(){ done(); });
});
