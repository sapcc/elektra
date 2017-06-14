ReactHelpers = {}

ReactHelpers.mergeObjects = (obj1,obj2,obj3={}) ->
  result = {}
  result[key] = obj1[key] for key of obj1
  result[key] = obj2[key] for key of obj2
  result[key] = obj3[key] for key of obj3
  result

ReactHelpers.cloneHashMap=(obj)->
  JSON.parse(JSON.stringify( obj ))

ReactHelpers.findIndexInArray=(items,itemId, itemIdKey = 'id') ->
  index=-1
  for item,i in items
    if item[itemIdKey]==itemId
      index=i
      break
  index

ReactHelpers.findInArray=(items,itemId) ->
  item = null
  for i in items
    if i.id==itemId
      item = i
      break
  item

@ReactHelpers = ReactHelpers
