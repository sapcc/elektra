ReactHelpers = {}

ReactHelpers.mergeObjects = (obj1,obj2,obj3={}) ->
  result = {}
  result[key] = obj1[key] for key of obj1
  result[key] = obj2[key] for key of obj2
  result[key] = obj3[key] for key of obj3
  result

ReactHelpers.cloneHashMap = (obj)->
  JSON.parse(JSON.stringify( obj ))

ReactHelpers.findIndexInArray = (items,itemId, itemIdKey = 'id') ->
  index=-1
  for item,i in items
    if item[itemIdKey]==itemId
      index=i
      break
  index

ReactHelpers.findInArray = (items,itemId) ->
  item = null
  for i in items
    if i.id==itemId
      item = i
      break
  item

# check if two arrays are equal
ReactHelpers.arrayEqual = (a, b) ->
  a.length is b.length and a.every (elem, i) -> elem is b[i]

# Returns an array with only unique values (doesn't work for arrays of objects)
ReactHelpers.arrayOnlyUnique = (arr) ->
  arr.filter((value, index, self) -> self.indexOf(value) == index )

# Updates attributes of items in an item list in state. Updates are passed as a hash map (attribute-key: attribute-value)
ReactHelpers.updateItemInList = (state, itemId, itemIdKey, updates = {}) ->
  index = ReactHelpers.findIndexInArray(state.items, itemId, itemIdKey)
  return state if index<0

  newState = ReactHelpers.cloneHashMap(state)
  for key,value of updates
    newState.items[index][key] = value

  newState


# Get value of given attribute from item in list
ReactHelpers.getItemAttribute = (items, itemId, itemIdKey, attributeKey) ->
  index = ReactHelpers.findIndexInArray(items, itemId, itemIdKey)
  return '' if index<0

  items[index][attributeKey]


# Check if given value exists (not undefined, not null) and has length 0
ReactHelpers.isEmpty = (s) ->
  return true if s? && s.length == 0




window.ReactHelpers = ReactHelpers
