###
AwesomeGrid v2.0.0
http://bhittani.com/javascript/awesome-grid
A minimalist javascript library that allows you to display a responsive grid
layout stacked on top of each other into rows and columns.
The MIT License (MIT)
Copyright (c) 2015 M. Kamal Khan <shout@bhittani.com>
###
class window.AwesomeGrid

    __els : []
    __kids : []
    __watch : null
    __columns : [0]
    __devices : ['small']
    __current : null
    __screen : null
    __small : null
    __mobile : null
    __tablet : null
    __desktop : null
    __tv : null

    constructor : (selector, isel = no) ->
        @__els = if isel then [selector] else document.querySelectorAll selector
        return @ if not @__els
        for el,e in @__els
            el.style.position = 'relative'
            @__kids[e] = el.children.length
            for child in el.children
                child.style.position = 'absolute'
                child.style.margin = 0
        @_reset()
        @__current = @__small
        @_respond()
        @_doresize()

    _reset : ->
        @__columns = [0]
        @__devices = ['small']
        @__small =
            device  : 'small'
            screen  : 0
            columns : 1
            gutters :
                column : 0
                row    : 0
                force  : no
        @__mobile =
            device  : 'mobile'
            screen  : 420
            columns : 1
            gutters :
                column : 0
                row    : 0
                force  : no
        @__tablet =
            device  : 'tablet'
            screen  : 768
            columns : 1
            gutters :
                column : 0
                row    : 0
                force  : no
        @__desktop =
            device  : 'desktop'
            screen  : 992
            columns : 1
            gutters :
                column : 0
                row    : 0
                force  : no
        @__tv =
            device  : 'tv'
            screen  : 1200
            columns : 1
            gutters :
                column : 0
                row    : 0
                force  : no

    _device : (which, columns, gutters, force) ->
        return @ if not @__els
        if columns is no
            @__devices = (x for x in @__devices when x isnt which)
        else
            device = switch
                when which is 'tv'      then @__tv
                when which is 'desktop' then @__desktop
                when which is 'tablet'  then @__tablet
                when which is 'mobile'  then @__mobile
            device.columns = columns
            @gutters gutters, force, device
            @__devices.push which if which not in @__devices
        @_respond()

    _respond : (size = window.innerWidth) ->
        #size = window.innerWidth
        @__screen = switch
            when size >= @__tv.screen      then @__tv
            when size >= @__desktop.screen then @__desktop
            when size >= @__tablet.screen  then @__tablet
            when size >= @__mobile.screen  then @__mobile
            else @__small
        @__current = switch
            when @__screen.device in @__devices then @__screen
            when @__screen.device is 'tv' and 'tv' in @__devices then @__tv
            when @__screen.device in ['tv', 'desktop'] and 'desktop' in @__devices then @__desktop
            when @__screen.device in ['tv', 'desktop', 'tablet'] and 'tablet' in @__devices then @__tablet
            when @__screen.device in ['tv', 'desktop', 'tablet', 'mobile'] and 'mobile' in @__devices then @__mobile
            else @__small
        @grid off

    _doresize : ->
        resizeTimeout = null
        window.addEventListener 'resize', =>
            if not resizeTimeout?
                resizeTimeout = setTimeout =>
                    resizeTimeout = null
                    @_respond()
                , 66 # 15fps
        , yes

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

    _giant : (from = -1, to = -1) ->
        return from if from is to and from > -1
        # much faster than looping
        if from is to and from is -1
            return @__columns.indexOf Math.max.apply null, @__columns
        # between
        g = @__columns[from..to]
        from + g.indexOf Math.max.apply null, g

    _midget : (from = -1, to = -1) ->
        return from if from is to and from > -1
        # much faster than looping
        if from is to and from is -1
            return @__columns.indexOf Math.min.apply null, @__columns
        # between
        m = @__columns[from..to]
        from + m.indexOf Math.min.apply null, m

    _clearClass : (el) ->
        className = el.className.replace ///
            (?:^|\s)
            (ag-col-.+?)|(ag-row-.+?)
            (?!\S)
        ///img, ''
        if className isnt ''
            className = className.trim() + ' '
        className

    _gutters : (obj) ->
        return @ if not @__els or not obj?
        gutters
        if (not isNaN obj) and (((z) -> (z | 0) is z ) parseFloat obj)
            return {
                column : parseInt obj
                row    : parseInt obj
            }
        gutters =
            column : @__small.gutters.column
            row    : @__small.gutters.row
        gutters.column = parseInt obj.column if obj.column? and (
            not isNaN obj.column
        ) and (
            ((z) -> (z | 0) is z ) parseFloat obj.column
        )
        gutters.row = parseInt obj.row if obj.row? and (
            not isNaN obj.row
        ) and (
            ((z) -> (z | 0) is z ) parseFloat obj.row
        )
        gutters

    gutters : (obj, force = no, device = @__small) ->
        return @ if not @__els
        g = @_gutters obj
        device.gutters =
            column : g.column
            row    : g.row
            force  : if force then yes else no
        @

    grid : (columns) ->
        return @ if not @__els
        @__small.columns = columns if columns
        device = @__current
        columns = device.columns
        return @ if not ((not isNaN columns) and (
            ((z) -> (z | 0) is z ) parseFloat columns
        ))
        for el in @__els
            # columns
            @__columns = (0 for [1..columns])
            rows = @__columns.slice 0
            # data-ag-gutters
            gutters = @_clone device.gutters
            if not gutters.force
                @gutters (el.getAttribute 'data-ag-gutters') or (
                    column : el.getAttribute 'data-ag-gutters-column'
                    row    : el.getAttribute 'data-ag-gutters-row'
                )
            width = (el.offsetWidth - ((columns - 1) * device.gutters.column)) / columns
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
                left = (c * width) + (c * device.gutters.column)
                # width
                w = (size * width) + ((size - 1) * device.gutters.column)
                # padding and border
                s = @_spacing child

                tallest = @_giant c, c + size - 1

                child.style.width = "#{w - s.pl - s.pr - s.bl - s.br}px"
                child.style.top   = "#{@__columns[tallest]}px"
                child.style.left  = "#{left}px"
                child.className   = @_clearClass child
                @__columns[tallest] = @__columns[tallest] + child.offsetHeight + device.gutters.row
                space = ''
                tr = []
                for ci in [c..(c + size - 1)]
                    child.className += "#{space}ag-col-#{ci+1}"
                    child.className += " ag-row-#{rows[ci]+1}" if rows[ci] not in tr
                    tr.push rows[ci]
                    rows[ci]++
                    space = ' '
                    @__columns[ci] = @__columns[tallest]

                el.style.height = "#{@__columns[@_giant()]}px"
            device.gutters = gutters
        @

    watch : (w = yes)->
        return @ if not @__els
        if not w
            clearTimeout @__watch if @__watch?
            return @
        for kids,e in @__kids
            children = @__els[e].children.length
            if children > kids
                @__kids[e] = children
                @grid @__columns.length
                break
        t = 66
        t = parseInt w if (not isNaN w) and (
            ((z) -> (z | 0) is z ) parseFloat w
        )
        @__watch = setTimeout =>
            @watch w
        , t
        @

    stop : ->
        return @ if not @__els
        @watch no
        @

    mobile : (columns, gutters = {}, force = no) ->
        @_device 'mobile', columns, gutters, force
        @

    tablet : (columns, gutters = {}, force = no) ->
        @_device 'tablet', columns, gutters, force
        @

    desktop : (columns, gutters = {}, force = no) ->
        @_device 'desktop', columns, gutters, force
        @

    tv : (columns, gutters = {}, force = no) ->
        @_device 'tv', columns, gutters, force
        @

# Launch grids based on data-attribute
window.addEventListener 'load', ->
    for el in (document.querySelectorAll '[data-awesome-grid]')
        (new AwesomeGrid el, yes).grid el.getAttribute 'data-awesome-grid'
, yes

# Support AMD (requirejs)
if (typeof window.define is 'function') and window.define.amd
    window.define 'AwesomeGrid', [], -> window.AwesomeGrid
