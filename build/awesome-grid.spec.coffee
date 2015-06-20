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
    TODO: Fails under test for reasons yet unknown
    it 'should also work via data attribute data-awesome-grid="[int]"', ->
        ($j 'ul[data-awesome-grid="5"] > li').each (i, el) ->
            (expect ($j @).outerWidth()).toBe 100
            (expect $j @).toHaveClass "ag-col-#{i+1}"
            (expect $j @).toHaveCss
                top: '0px'
                left: "#{i*100}px"
    ###
    it 'should silently fail if DOM selector not found', (done) ->
        (new AwesomeGrid 'ul.invalid')
        .gutters
            column : 10
            row    : 10
        .grid 5
        done()



#
