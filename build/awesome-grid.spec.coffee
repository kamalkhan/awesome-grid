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
    it 'should attach a DOM selector', ->
        (expect $j Grid.__el).toEqual 'ul.grid'
    it 'should position the selector as relative', ->
        (expect $el).toHaveCss
            position: 'relative'
    it 'should recognize immediate child tag', ->
        (expect Grid.__itemsTag).toBe 'li'
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
    it 'should split items into * number of columns', ->
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
            #top =
            (expect $j @).toHaveCss
                top: "#{(i*($j @).outerHeight())}px"
                left: '0px'
    it 'should allow for adding gutters', ->
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
    it 'should silently fail if DOM selector not found', (done) ->
        (new AwesomeGrid 'ul.invalid')
        .gutters
            column : 10
            row    : 10
        .grid 5
        done()



#
