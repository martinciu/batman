helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

class MockRequest extends MockClass
  @chainedCallback 'success'
  @chainedCallback 'error'
oldRequest = Batman.Request
QUnit.module 'Batman.View partial rendering'
  setup: ->
    MockRequest.reset()
    Batman.Request = MockRequest

  teardown: ->
    Batman.View.sourceCache = new Batman.ViewSourceCache
    Batman.Request = oldRequest

asyncTest "preloaded/already rendered partials should render", ->
  Batman.View.sourceCache =
    get: (k) ->
      equal k, '/views/test/one'
      "<div>Hello from a partial</div>"

  source = '<div data-partial="test/one"></div>'
  node = helpers.render source, {}, (node) ->
    delay =>
      equals node.children(0).children(0).html(), "Hello from a partial"

asyncTest "unloaded partials should load then render", 2, ->
  source = '<div data-partial="test/one"></div>'

  # Callback below doesn't fire until view's ready event, which waits for the partial to be fetched and rendered.
  node = helpers.render source, {}, (node) ->
    equal node.children(0).children(0).html(), "Hello from a partial"
    QUnit.start()

  setTimeout ->
    equal MockRequest.lastInstance.constructorArguments[0].url, "/views/test/one.html"
    MockRequest.lastInstance.fireSuccess('<div>Hello from a partial</div>')
  , ASYNC_TEST_DELAY

asyncTest "unloaded partials should only load once", ->
  source = '<div data-foreach-object="objects">
              <div data-partial="test/one"></div>
            </div>'

  context = Batman
    objects: new Batman.Set(1,2,3,4)

  node = helpers.render source, context, (node) ->
    equal node.children(0).children(0).children(0).html(), "Hello from a partial"
    QUnit.start()

  setTimeout ->
    equal MockRequest.instanceCount, 1
    MockRequest.lastInstance.fireSuccess('<div>Hello from a partial</div>')
  , ASYNC_TEST_DELAY

asyncTest "data-defineview bindings can be used to embed view contents", ->
  source = '<div data-defineview="test/view">
              <p data-bind="foo"></p>
            </div>
            <div>
              <p data-partial="test/view"></p>
            </div>'

  context = Batman
    foo: 'bar'

  node = helpers.render source, context, (node) ->
    equal node.length, 1
    equal node.children(0).children(0).children(0).html(), 'bar'
    QUnit.start()
