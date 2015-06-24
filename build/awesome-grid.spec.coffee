jasmine.getFixtures().fixturesPath = 'base/build'
jasmine.getStyleFixtures().fixturesPath = 'base/build'

$el = null
$li = null
beforeEach ->
    loadFixtures 'fixture.html'
    loadStyleFixtures 'fixture.css'
    $el = $j 'ul.grid'
    $li = $el.find '>li'

describe 'ul.grid', ->

    it 'should be in the DOM', ->
        (expect $el[0]).toBeInDOM()
    it 'should be 500px wide', ->
        (expect $el.width()).toBe 500

describe 'ul.grid > li', ->

    it 'should be a total of 5', ->
        (expect $li.length).toBe 5
    it 'should each be 500px wide', ->
        $li.each (i, el) ->
            (expect ($j @).outerWidth()).toBe 500

describe 'AwesomeGrid', ->

    it 'should be defined', ->
        (expect window.AwesomeGrid).toBeDefined()
    Grid = null
    beforeEach -> Grid = (new AwesomeGrid 'ul.grid')
    it 'should position the selector as relative', ->
        (expect $el).toHaveCss
            position: 'relative'
    it 'should position the children as absolute', ->
        $li.each (i, el) ->
            (expect $j @).toHaveCss
                position: 'absolute'
    it 'should unmarginalize the children', ->
        $li.each (i, el) ->
            (expect $j @).toHaveCss
                marginTop:    '0px'
                marginBottom: '0px'
                marginLeft:   '0px'
                marginRight:  '0px'

describe 'Generally', ->

    Grid = null
    beforeEach -> Grid = (new AwesomeGrid 'ul.grid')

    it 'should spread children into * number of columns using .grid([int])', ->
        Grid.grid 5
        $li.each (i, el) ->
            (expect ($j @).outerWidth()).toBe 100
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{i*100}px"
        Grid.grid 1
        $li.each (i, el) ->
            (expect ($j @).outerWidth()).toBe 500
            (expect $j @).toHaveClass "ag-col-1"
            (expect $j @).toHaveCss
                top: "#{i*($j @).outerHeight()}px"
                left: '0px'
    it 'should allow for adding gutters using .gutters({column:[int],row:[int]})', ->
        Grid.gutters
            column : 10
            row    : 10
        .grid 3
        ii = 0
        $li.each (i, el) ->
            # (size - (col - 1) * gutter.col) / col
            # 500   - 2         * 10          / 3
            (expect ($j @).outerWidth()).toBe 160
            (expect $j @).toHaveCss
                top: if i < 3 then '0px' else "#{(10 + ($j @).outerHeight())}px"
                left: "#{(ii*160)+(ii*10)}px" # 0 + 0, 160 + 10, 320 + 20 ...
            ii++
            if i is 2 then ii = 0
    it 'should allow for adding gutters using .gutters([int])', ->
        Grid.gutters 10
        .grid 3
        ii = 0
        $li.each (i, el) ->
            (expect ($j @).outerWidth()).toBe 160
            (expect $j @).toHaveCss
                top: if i < 3 then '0px' else "#{(10 + ($j @).outerHeight())}px"
                left: "#{(ii*160)+(ii*10)}px"
            ii++
            if i is 2 then ii = 0
    it 'should adopt new children using .apply()', ->
        $el = $j 'ul.watch'
        Grid = (new AwesomeGrid 'ul.watch').grid 5
        $el.append '<li>6</li>'
        Grid.apply()
        $li = $j '>li:last-child', $el
        (expect $li.outerWidth()).toBe 100
        (expect $li).toHaveClass 'ag-col-1'
        (expect $li).toHaveCss
            top: "#{$li.outerHeight()}px"
            left: '0px'
    ###
    # Ignore the scroll test due to phantomjs browser.
    it 'should allow providing new data when scrolled using .scroll([fn])', (done) ->
        Grid.grid 5
        .scroll (fn) ->
            console.log fn
            done()
        ($j 'body,html').scrollTop 9999
    ###
    it 'should silently fail if DOM selector isn\'t found', (done) ->
        (new AwesomeGrid 'ul.invalid')
        .gutters
            column : 10
            row    : 10
        .grid 5
        done()

describe 'With the help of data-ag-* attributes', ->

    it 'should allow for adding gutters using data attributes', ->
        (new AwesomeGrid 'ul.with-gutters1').grid 3
        ii = 0
        ($j 'ul.with-gutters1 > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 160
            (expect $j @).toHaveCss
                top: if i < 3 then '0px' else "#{(10 + ($j @).outerHeight())}px"
                left: "#{(ii*160)+(ii*10)}px"
            ii++
            if i is 2 then ii = 0
        (new AwesomeGrid 'ul.with-gutters2').grid 3
        ii = 0
        ($j 'ul.with-gutters2 > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 160
            (expect $j @).toHaveCss
                top: if i < 3 then '0px' else "#{(10 + ($j @).outerHeight())}px"
                left: "#{(ii*160)+(ii*10)}px"
            ii++
            if i is 2 then ii = 0
    it 'should prefer data attributed gutters over js provided gutters', ->
        (new AwesomeGrid 'ul.data-gutters-over-js')
        .gutters 0
        .grid 5
        ($j 'ul.data-gutters-over-js default > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 100
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{i*100}px"
        ($j 'ul.data-gutters-over-js[data-ag-gutters="10"] > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 92
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*92)+(i*10)}px"
    it 'should allow forcing js provided gutters over data attributed gutters', ->
        (new AwesomeGrid 'ul.with-gutters1')
        .gutters 0, yes # force
        .grid 5
        ($j 'ul.with-gutters1 > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 100
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{i*100}px"
    it 'should stretch children based on data-ag-x attribute', ->
        (new AwesomeGrid 'ul.with-stretch').grid 5
        ($j 'ul.with-stretch > li').each (i, el) ->
            if i is 0
                (expect ($j @).outerWidth()).toBe 200
                (expect $j @).toHaveClass 'ag-col-1 ag-row-1 ag-col-2'
                (expect $j @).toHaveCss
                    top: '0px'
                    left: '0px'
            else if i is 3
                (expect ($j @).outerWidth()).toBe 300
                (expect $j @).toHaveClass 'ag-col-3 ag-row-2 ag-col-4 ag-col-5'
                (expect $j @).toHaveCss
                    top: "#{($j @).outerHeight()}px"
                    left: '200px'
            else
                (expect $j @).toHaveClass (if i is 4 then 'ag-col-1' else "ag-col-#{i+2}")
    ###
    # Omit this test for now. Does not play well in test case.
    it 'should work via data attribute data-awesome-grid="[int]"', (done) ->
        window.addEventListener 'load', ->
            ($j 'ul[data-awesome-grid="5"] > li').each (i, el) ->
                (expect ($j @).outerWidth()).toBe 100
                (expect $j @).toHaveClass "ag-col-#{i+1}"
                (expect $j @).toHaveCss
                    top: '0px'
                    left: "#{i*100}px"
            done()
    ###

describe 'When using a mobile (screen)', ->

    it 'should respond using .mobile([int])', ->
        el = 'ul.responsive'
        ($j el).width 300
        (new AwesomeGrid el).grid 2
        .mobile 5
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 60
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{i*60}px"
    it 'should apply gutters using .mobile([int], {column:[int],row:[int]})', ->
        el = 'ul.responsive'
        ($j el).width 300
        (new AwesomeGrid el)
        .gutters 10
        .mobile 5,
            column : 10
            row : 10
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 52
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*52)+(i*10)}px"
    it 'should apply gutters using .mobile([int], [int])', ->
        el = 'ul.responsive'
        ($j el).width 300
        (new AwesomeGrid el)
        .gutters 10
        .mobile 5, 10
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 52
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*52)+(i*10)}px"

describe 'When using a tablet (screen)', ->

    it 'should respond using .tablet([int])', ->
        el = 'ul.responsive'
        ($j el).width 800
        (new AwesomeGrid el)
        .tablet 8
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 100
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{i*100}px"
    it 'should apply gutters using .tablet([int], {column:[int],row:[int]})', ->
        el = 'ul.responsive'
        ($j el).width 800
        (new AwesomeGrid el)
        .gutters 10
        .tablet 6,
            column : 10
            row : 10
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 125
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*125)+(i*10)}px"
    it 'should apply gutters using .tablet([int], [int])', ->
        el = 'ul.responsive'
        ($j el).width 800
        (new AwesomeGrid el)
        .gutters 10
        .tablet 6, 10
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 125
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*125)+(i*10)}px"

describe 'When using a desktop (screen)', ->

    it 'should respond using .desktop([int])', ->
        el = 'ul.responsive'
        ($j el).width 1024
        (new AwesomeGrid el)
        .tablet 8
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 128
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{i*128}px"
    it 'should apply gutters using .desktop([int], {column:[int],row:[int]})', ->
        el = 'ul.responsive'
        ($j el).width 1000
        (new AwesomeGrid el)
        .gutters 10
        .tablet 5,
            column : 10
            row : 10
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 192
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*192)+(i*10)}px"
    it 'should apply gutters using .desktop([int], [int])', ->
        el = 'ul.responsive'
        ($j el).width 1000
        (new AwesomeGrid el)
        .gutters 10
        .tablet 5, 10
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 192
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*192)+(i*10)}px"

describe 'When using a tv (screen)', ->

    it 'should respond using .tv([int])', ->
        el = 'ul.responsive'
        ($j el).width 1400
        (new AwesomeGrid el)
        .tablet 7
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 200
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{i*200}px"
    it 'should apply gutters using .tv([int], {column:[int],row:[int]})', ->
        el = 'ul.responsive'
        ($j el).width 1400
        (new AwesomeGrid el)
        .gutters 10
        .tablet 6,
            column : 10
            row : 10
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 225
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*225)+(i*10)}px"
    it 'should apply gutters using .tv([int], [int])', ->
        el = 'ul.responsive'
        ($j el).width 1400
        (new AwesomeGrid el)
        .gutters 10
        .tv 6, 10
        ($j el + ' > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 225
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{(i*225)+(i*10)}px"

describe 'Events', ->

    Grid = null
    beforeEach -> Grid = (new AwesomeGrid 'ul.grid')
    it 'should emit \'item:stacked\' when an item is stacked onto the grid', ->
        e = 0
        Grid.on 'item:stacked', (ev, el, row, column, device) ->
            e++
        .grid 5
        (expect e).toBe 5
    it 'should emit \'grid:done\' when grid is completely stacked', ->
        e = 0
        Grid.on 'grid:done', (ev, screen) ->
            e++
        .grid 5
        (expect e).toBe 1
    # Can not test this
    it 'should emit \'grid:scrolled\' when grid is scrolled to the bottom', (done) ->
        done()
    # Can not test this
    it 'should emit \'grid:device\' when grid changes its device (screen size)', (done) ->
        Grid.on 'grid:device', (ev, device, previous) ->
            (expect device).toEqual 'small'
            done()
        .grid 5
    it 'should turn off an event when using .off([string], [fn])', ->
        e = 0
        fn = (ev, el, row, column, device) ->
            e++
        Grid.on 'item:stacked', fn
        .off 'item:stacked', fn
        .grid 5
        (expect e).toBe 0
    it 'should turn off all events of * when using .off([string])', ->
        e = 0
        fn1 = (ev, el, row, column, device) ->
            e++
        fn2 = (ev) ->
            e++
        Grid.on 'item:stacked', fn1
        .on 'item:stacked', fn2
        .off 'item:stacked'
        .grid 5
        (expect e).toBe 0
    it 'should turn off all events when using .off()', ->
        e = 0
        fn1 = (ev, el, row, column, device) ->
            e++
        fn2 = (el) ->
            e++
        Grid.on 'item:stacked', fn1
        .on 'item:stacked', fn2
        .off()
        .grid 5
        (expect e).toBe 0
