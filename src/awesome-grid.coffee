###
AwesomeGrid v2.0.0
https://github.com/kamalkhan/awesome-grid
A minimalist javascript library that allows you to display a responsive grid
layout stacked on top of each other into rows and columns.
The MIT License (MIT)
Copyright (c) 2015 M. Kamal Khan <shout@bhittani.com>
###
class AwesomeGrid

    __els : []
    __kids : []
    __watch : null
    __adopt : no
    __width : null
    __rows : [0]
    __columns : [0]
    __scroll :
        watch  : null
        fn     : null

    __devices : null
    __current : null
    __screen : null
    __small : null
    __mobile : null
    __tablet : null
    __desktop : null
    __tv : null

    __events : []

    __context : null

    @options :
        context : 'window'
        mobile  : 420
        tablet  : 768
        desktop : 992
        tv      : 1200

    constructor : (selector, args = AwesomeGrid.options, isel = no) ->
        @__els = if isel then [selector] else document.querySelectorAll selector
        return @ if not @__els
        for el,e in @__els
            el.style.position = 'relative'
            @__kids[e] = el.children.length
            for child in el.children
                child.style.position = 'absolute'
                child.style.margin = 0
        @_reset @_merge AwesomeGrid.options, args
        @_respond()
        @_docontext()
        @_doresize()
        @_doscroll()

    _make : (name, screen) ->
        {
            device  : name
            screen  : screen
            columns : 1
            gutters :
                column : 0
                row    : 0
                force  : no
        }

    _reset : (options) ->
        @__context = options.context
        @__small   = @_make 'small',   0
        @__mobile  = @_make 'mobile',  options.mobile
        @__tablet  = @_make 'tablet',  options.tablet
        @__desktop = @_make 'desktop', options.desktop
        @__tv      = @_make 'tv',      options.tv
        @__columns = [0]
        @__devices = ['small']
        @__current = {}#@__small

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
        respond = (size, els) =>
            @__screen = switch
                when size >= @__tv.screen      then @__tv
                when size >= @__desktop.screen then @__desktop
                when size >= @__tablet.screen  then @__tablet
                when size >= @__mobile.screen  then @__mobile
                else @__small
            device = @__current.device
            @__current = switch
                when @__screen.device in @__devices then @__screen
                when @__screen.device is 'tv' and 'tv' in @__devices then @__tv
                when @__screen.device in ['tv', 'desktop'] and 'desktop' in @__devices then @__desktop
                when @__screen.device in ['tv', 'desktop', 'tablet'] and 'tablet' in @__devices then @__tablet
                when @__screen.device in ['tv', 'desktop', 'tablet', 'mobile'] and 'mobile' in @__devices then @__mobile
                else @__small
            if @__current.device isnt device
                @_emit 'grid:device', null, [@__current.device, device]
            @grid off, els

        if @__context is 'self'
            for el in @__els
                respond el.offsetWidth, [el]
        else respond size, @__els

    _docontext : ->
        return null if @__context isnt 'self'
        @_respond()
        @__watch = setTimeout =>
            @_docontext()
        , 220 # 50fps

    _doresize : ->
        return null if @__context is 'self'
        timeout = null
        window.addEventListener 'resize', =>
            if not timeout?
                timeout = setTimeout =>
                    timeout = null
                    @_respond()
                , 66 # 15fps
        , yes

    _grow : ->
        # X do not return in order to emit scroll event
        return @ if not @__scroll.fn? or @__scroll.watch?
        for el,e in @__els
            style = getComputedStyle el
            height = parseInt style.getPropertyValue 'height'
            ### should we use this?
            offsetTop = ((el) ->
                box = el.getBoundingClientRect()
                body = document.body;
                docEl = document.documentElement;
                scrollTop = window.pageYOffset or docEl.scrollTop or body.scrollTop
                scrollLeft = window.pageXOffset or docEl.scrollLeft or body.scrollLeft
                clientTop = docEl.clientTop or body.clientTop or 0
                clientLeft = docEl.clientLeft or body.clientLeft or 0
                top  = box.top +  scrollTop - clientTop
                #left = box.left + scrollLeft - clientLeft
                Math.round top
            ) el
            ###
            if document.body.scrollTop >= height + el.offsetTop - window.innerHeight
                @_emit 'grid:scrolled', el, [@__current.device]
                #return @ if (not @__scroll.fn?) or @__scroll.watch?
                @__scroll.watch = yes
                x = e # why does e change inside the callback :(
                @__scroll.fn =>
                    if not arguments.length or not arguments[0]
                        @__scroll.watch = null
                        return @
                    if arguments[0].constructor is Array
                        children = arguments[0]
                    else children = arguments
                    for child in children
                        tag = el.children[0].tagName.toLowerCase()
                        tel = document.createElement tag
                        tel.innerHTML = child
                        el.appendChild tel
                    @_sync x
                    @__scroll.watch = null
    _doscroll : ->
        timeout = null
        window.addEventListener 'scroll', =>
            if not timeout?
                timeout = setTimeout =>
                    timeout = null
                    @_grow()
                , 66 # 15fps
        , yes

    _isInt : (n) ->
        # http://stackoverflow.com/questions/14636536/#14794066
        n? and (not isNaN n) and (
            ((z) -> (z | 0) is z ) parseFloat n
        )

    _clone : (obj) ->
        return obj if not obj? or typeof obj isnt 'object'
        temp = {}
        temp[key] = @_clone(obj[key]) for key of obj
        temp

    _merge : (obj1, obj2) ->
        obj = @_clone obj1
        for key,val of obj2
            obj[key] = val
        obj

    _x : (el, max) ->
        size = 1
        x = el.getAttribute 'data-ag-x'
        size = parseInt x if @_isInt x
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

    _emit : (event, context, args) ->
        for ev in @__events
            if ev[0] is event
                ev[1].apply context, [event].concat args

    _gutters : (obj) ->
        return @ if not @__els or not obj?
        return {
            column : parseInt obj
            row    : parseInt obj
        } if @_isInt obj
        gutters =
            column : @__small.gutters.column
            row    : @__small.gutters.row
        gutters.column = parseInt obj.column if @_isInt obj.column
        gutters.row = parseInt obj.row if @_isInt obj.row
        gutters

    _grid : (pel, el, columns, dynamic = no) ->
        if dynamic
            el.style.position = 'absolute'
            el.style.margin = 0
        # column index
        c = @_midget()
        # data-x
        size = @_x el, columns
        if (c + size) > columns
            c -= c + size - columns
        # left position
        left = (c * @__width) + (c * @__current.gutters.column)
        # width
        w = (size * @__width) + ((size - 1) * @__current.gutters.column)
        # padding and border
        s = @_spacing el
        # tallest columns
        tallest = @_giant c, c + size - 1
        # apply styling
        el.style.width = "#{w - s.pl - s.pr - s.bl - s.br}px"
        el.style.top   = "#{@__columns[tallest]}px"
        el.style.left  = "#{left}px"
        el.className   = @_clearClass el
        @__columns[tallest] = @__columns[tallest] + el.offsetHeight + @__current.gutters.row
        # apply class names (ag-row-* and ag-col-*)
        space = ''
        tr = []
        cols = []
        rows = []
        for ci in [c..(c + size - 1)]
            el.className += "#{space}ag-col-#{ci+1}"
            el.className += " ag-row-#{@__rows[ci]+1}" if @__rows[ci] not in tr
            tr.push @__rows[ci]
            @__rows[ci]++
            space = ' '
            @__columns[ci] = @__columns[tallest]
            cols.push (ci + 1)
            rows.push @__rows[ci]
        # enlarge container
        pel.style.height = "#{@__columns[@_giant()]}px"
        # event
        @_emit 'item:stacked', el, [pel, rows, cols, @__current.device]

    _sync : (e) ->
        kids = @__kids[e]
        children = @__els[e].children.length
        if children > kids
            @__kids[e] = children
            for c in [kids...children]
                @_grid @__els[e], @__els[e].children[c], @__columns.length, yes

    gutters : (obj, force = no, device = @__small) ->
        return @ if not @__els
        g = @_gutters obj
        device.gutters =
            column : g.column
            row    : g.row
            force  : if force then yes else no
        @

    grid : (columns, els = @__els) ->
        return @ if not @__els
        @__small.columns = columns if columns
        device = @__current
        columns = device.columns
        return @ if not @_isInt columns
        for el in els
            # columns
            @__columns = (0 for [1..columns])
            @__rows = @__columns.slice 0
            gutters = @_clone device.gutters
            # data-ag-gutters
            if not gutters.force
                @gutters (el.getAttribute 'data-ag-gutters') or (
                    column : el.getAttribute 'data-ag-gutters-column'
                    row    : el.getAttribute 'data-ag-gutters-row'
                ), device
            @__width = (el.offsetWidth - ((columns - 1) * device.gutters.column)) / columns
            for child in el.children
                @_grid el, child, columns
            device.gutters = gutters
            # event
            @_emit 'grid:done', el, [device.device]
        @

    apply : ->
        for kids,e in @__kids
            @_sync e
        @

    scroll : (fn) ->
        if fn is off
            @__scroll.fn = null
            @__scroll.watch  = null
            return @
        return @ if typeof fn isnt 'function'
        @__scroll.fn = fn
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

    on : (event, fn) ->
        return @ if typeof fn isnt 'function'
        @__events.push [event, fn]
        @

    off : (event, fn = null) ->
        if not event?
            @__events = []
            return @
        events = []
        for ev, e in @__events
            if ev[0] isnt event or (fn? and fn.toString() isnt ev[1].toString())
                events.push ev
        @__events = events
        @

# Launch grids based on data-attribute
window.addEventListener 'load', ->
    for el in (document.querySelectorAll '[data-awesome-grid]')
        (new AwesomeGrid el, AwesomeGrid.options, yes).grid el.getAttribute 'data-awesome-grid'
, yes

# Support global window
if window?
    window.AwesomeGrid = AwesomeGrid

# Support AMD (requirejs)
if (typeof define is 'function') and define.amd
    define 'AwesomeGrid', [], -> AwesomeGrid

# Support CommonJS (npm)
if module?.exports
    module.exports = AwesomeGrid
