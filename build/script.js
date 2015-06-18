var gulp   = require('gulp');
var gutil  = require('gulp-util');
var coffee = require('gulp-coffee');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename')
var watch  = require('gulp-watch');
var notify = require('gulp-notify');

var srcFile  = __dirname + '/../src/awesome-grid.coffee';
var dest     = __dirname + '/..';

gulp.task('js', function(){
    gulp.src(srcFile)
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest(dest))
    .pipe(uglify())
    .pipe(rename({extname: '.min.js'}))
    .pipe(gulp.dest(dest))
    .pipe(notify("Coffee stirred & minified"));
});

gulp.task('js-watch', function(){
    gulp.start('js');
    watch([srcFile], function(files){
        gulp.start('js')
    });
});
