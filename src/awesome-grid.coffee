class window.AwesomeGrid

    __el : null
    __itemsTag : null
    __columns : null
    __cols : []
    __gutterColumns : 0
    __gutterRows : 0

    constructor : (selector) ->
        @__el = document.querySelector selector
        if not @__el then return @
        @__itemsTag = @__el.children[0].tagName.toLowerCase()
        @__el.style.position = 'relative'
        for item in @__el.children
            item.style.position = 'absolute'
            item.style.margin = 0

    _giant : ->
        giant = -1
        key = 0
        for c,i in @__cols
            if c.height > giant or giant is -1
                key = i
                giant = c.height
        key

    _midget : ->
        midget = -1
        key = 0
        for c,i in @__cols
            if c.height < midget or midget is -1
                key = i
                midget = c.height
        key

    _clearClass : (el) ->
        className = el.className.replace ///
            (?:^|\s)
            ag-col-.+?
            (?!\S)
        ///img, ''
        if className isnt ''
            className = className.trim() + ' '
        className

    gutters : (obj) ->
        if not @__el then return @
        @__gutterColumns = obj.column if obj.column?
        @__gutterRows    = obj.row    if obj.row?
        @

    grid : (amount) ->
        if not @__el then return @
        if @__columns is amount then return @
        @__cols = []
        @__columns = amount
        width = ((@__el.offsetWidth - ((amount - 1) * @__gutterColumns)) / amount)
        for c in [(amount-amount)...amount] by 1
            @__cols.push
                left : (c * width) + (c * @__gutterColumns)
                height : 0
        for item in @__el.children
            key = @_midget()
            style = getComputedStyle item
            pl = parseInt style.paddingLeft
            pr = parseInt style.paddingRight
            bl = parseInt style.getPropertyValue 'border-left-width'
            br = parseInt style.getPropertyValue 'border-right-width'
            item.style.width = "#{width-pl-pr-bl-br}px"
            item.style.top   = "#{@__cols[key].height}px"
            item.style.left  = "#{@__cols[key].left}px"
            item.className   = "#{@_clearClass item}ag-col-#{key+1}"
            @__cols[key].height += item.offsetHeight + @__gutterRows
            
            @__el.style.height = "#{@__cols[@_giant()].height}px"
        @

# Support AMD (requirejs)
if (typeof window.define is 'function') and window.define.amd
    window.define 'AwesomeGrid', [], -> window.AwesomeGrid
