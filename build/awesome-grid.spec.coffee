jasmine.getFixtures().fixturesPath = 'base/build'
jasmine.getStyleFixtures().fixturesPath = 'base/build'

#$el = undefined
describe 'test', ->
    beforeEach ->
        loadFixtures 'fixture.html'
        loadStyleFixtures 'fixture.css'
        #$el = $ 'span.kk-star-ratings'
    it 'should exist', ->
        (expect yes).toEqual yes
