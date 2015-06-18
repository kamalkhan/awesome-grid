require('./build/script');
require('./build/test');
require('gulp')
.task('default', [
    'js', 'test'
]);
