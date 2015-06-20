class window.AwesomeGrid

    __els : []
    __kids : []
    __watch : null
    __columns : [0]
    __gutters :
        column : 0
        row    : 0
        force  : no

    constructor : (selector, isel = no) ->
        @__els = if isel then [selector] else document.querySelectorAll selector
        return @ if not @__els

        for el,e in @__els
            el.style.position = 'relative'
            @__kids[e] = el.children.length
            for child in el.children
                child.style.position = 'absolute'
                child.style.margin = 0

    _clone : (obj) ->
        return obj if not obj? or typeof obj isnt 'object'
        temp = {}
        temp[key] = @_clone(obj[key]) for key of obj
        temp

    _x : (el, max) ->
        size = 1
        x = el.getAttribute 'data-ag-x'
        # http://stackoverflow.com/questions/14636536/#14794066
        size = parseInt x if x? and (not isNaN x) and (
            ((z) -> (z | 0) is z ) parseFloat x
        )
        if size > max then max else if size < 1 then 1 else size

    _spacing : (el) ->
        s = {}
        style = getComputedStyle el
        s.pl = parseInt style.paddingLeft
        s.pr = parseInt style.paddingRight
        s.bl = parseInt style.getPropertyValue 'border-left-width'
        s.br = parseInt style.getPropertyValue 'border-right-width'
        s

    _giant : (from = -1, to = -1)->
        return from if from is to and from > -1
        # much faster than looping
        if from is to and from is -1
            return @__columns.indexOf Math.max.apply null, @__columns
        # between
        g = @__columns[from..to]
        from + g.indexOf Math.max.apply null, g

    _midget : ->
        # much faster than looping
        @__columns.indexOf Math.min.apply null, @__columns

    _clearClass : (el) ->
        className = el.className.replace ///
            (?:^|\s)
            ag-col-.+?
            (?!\S)
        ///img, ''
        if className isnt ''
            className = className.trim() + ' '
        className

    gutters : (obj, force = no) ->
        return @ if not @__els or not obj?
        @__gutters.force = yes if force
        # if integer, set row and column
        if (not isNaN obj) and (((z) -> (z | 0) is z ) parseFloat obj)
            @__gutters.column = parseInt obj
            @__gutters.row    = parseInt obj
            return @
        @__gutters.column = parseInt obj.column if obj.column? and (
            not isNaN obj.column
        ) and (
            ((z) -> (z | 0) is z ) parseFloat obj.column
        )
        @__gutters.row = parseInt obj.row if obj.row? and (
            not isNaN obj.row
        ) and (
            ((z) -> (z | 0) is z ) parseFloat obj.row
        )
        @

    grid : (columns) ->
        return @ if not @__els
        return @ if not ((not isNaN columns) and (
            ((z) -> (z | 0) is z ) parseFloat columns
        ))
        for el in @__els
            # columns
            @__columns = (0 for [1..columns])
            # data-ag-gutters
            gutters = @_clone @__gutters
            if not @__gutters.force
                @gutters (el.getAttribute 'data-ag-gutters' or
                    column : el.getAttribute 'data-ag-gutters-column'
                    row    : el.getAttribute 'data-ag-gutters-row'
                )
            width = (el.offsetWidth - ((columns - 1) * @__gutters.column)) / columns
            for child in el.children
                child.style.position = 'absolute' # if added dynamically
                child.style.margin = 0 # if added dynamically
                # column index
                c = @_midget()
                # data-x
                size = @_x child, columns
                if (c + size) > columns
                    c -= c + size - columns
                # left position
                #left = (c * width) + (c * @__gutters.column)
                left = (c * width) + (c * @__gutters.column)
                # width
                w = (size * width) + ((size - 1) * @__gutters.column)
                # padding and border
                s = @_spacing child

                tallest = @_giant c, c + size - 1

                child.style.width = "#{w - s.pl - s.pr - s.bl - s.br}px"
                child.style.top   = "#{@__columns[tallest]}px"
                child.style.left  = "#{left}px"
                child.className   = "#{@_clearClass child}ag-col-#{c+1}"
                @__columns[tallest] = @__columns[tallest] + child.offsetHeight + @__gutters.row
                for ci in [c..(c + size - 1)]
                    @__columns[ci] = @__columns[tallest]

                el.style.height = "#{@__columns[@_giant()]}px"
            @__gutters = gutters
        @

    watch : (w = yes)->
        if not w
            clearTimeout @__watch if @__watch?
            return @
        for kids,e in @__kids
            children = @__els[e].children.length
            if children > kids
                @__kids[e] = children
                @grid @__columns.length
                break
        t = 30
        t = parseInt w if (not isNaN w) and (
            ((z) -> (z | 0) is z ) parseFloat w
        )
        @__watch = setTimeout =>
            @watch w
        , t
        @

    stop : ->
        @watch no

# Launch grids based on data-attribute
# Fails under test for reasons yet unknown
for el in (document.querySelectorAll '[data-awesome-grid]')
    (new AwesomeGrid el, yes).grid el.getAttribute 'data-awesome-grid'

# Support AMD (requirejs)
if (typeof window.define is 'function') and window.define.amd
    window.define 'AwesomeGrid', [], -> window.AwesomeGrid
