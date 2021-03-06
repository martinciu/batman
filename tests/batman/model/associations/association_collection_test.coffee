{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter} = if typeof require isnt 'undefined' then require '../model_helper' else window
helpers = if typeof require is 'undefined' then window.viewHelpers else require '../../view/view_helper'

QUnit.module "Batman.Model AssociationCollection",
  setup: ->
    class @Store extends Batman.Model
    class @Product extends Batman.Model
    class @ShopifyStore extends @Store

test "associations can be added", ->
  collection = new Batman.AssociationCollection(@Store)

  association = {associationType: 'belongsTo', label: 'products', model: @Product}
  collection.add association

  associationsObject = collection.getAll()

  equal associationsObject.get('belongsTo').get(association), 'products'

test "associations are inherited by subclasses", ->
  @Store._batman.check(@Store)
  @Store._batman.associations = parentCollection = new Batman.AssociationCollection(@Store)
  subClassCollection = new Batman.AssociationCollection(@ShopifyStore)

  association = {associationType: 'belongsTo', label: 'products', model: @Product}
  parentCollection.add association

  associationsObject = subClassCollection.getAll()

  equal associationsObject.get('belongsTo').get(association), 'products'
