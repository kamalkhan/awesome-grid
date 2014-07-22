Awesome Grid
======
A jQuery plugin that allows you to display a responsive grid layout stacked on top of each other into rows and columns.

## View Demo

You can view the [demo here](http://bhittani.com/jquery/awesome-grid)

## Usage

1. Link to the scripts
```
<script src="/path/to/jquery.js"></script>
<script src="/path/to/awesome-grid.min.js"></script>
```
2. Apply a grid layout to any element using the following code. Adjust the settings upon your discretion.
```
<script>
    $(window).load(function(){
        $('ul.grid').AwesomeGrid({
            rowSpacing  : 20,                // row gutter spacing
            colSpacing  : 20,                // column gutter spacing
            initSpacing : 0,                 // apply column spacing for the first elements
            responsive  : true,              // itching for responsiveness?
            fadeIn      : true,              // allow fadeIn effect for an element?
            hiddenClass : false,             // ignore an element having this class or false for none
            item        : 'li',              // item selector to stack on the grid
            onReady     : function(item){}   // callback fired when an element is stacked
            columns     : {                  // supply an object to display columns based on the viewport
                'defaults' : 4,              // default number of columns
                '800'      : 2               // when viewport <= 800, show 2 columns
            }                                // you can also use an integer instead of a json object if
                                             // you don't care about responsiveness
        });
    });
</script>
```

## License

This plugin is licensed under [MIT License](http://opensource.org/licenses/MIT). Feel free to use it in commercial projects as long as the copyright notices are intact.
