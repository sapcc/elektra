import React from "react"
import { STRINGS } from "./constants"

const perFlavorRx = /^instances_(.+)$/

// Translates API-level strings into user-readable UI strings,
// e.g. "volumev2" -> "Block Storage".
export const t = (str) => {
  const translated = STRINGS[str]
  if (translated) {
    return translated
  }

  //for baremetal flavor resources like "instances_zh2vic1.medium",
  //return the flavor name, e.g. "zh2vic1.medium"
  const match = perFlavorRx.exec(str)
  return match ? match[1] : str
}

// This can be used as a sorting predicate:
//     sorted_things = things.sort(byUIString)
export const byUIString = (a, b) => {
  const aa = t(a)
  const bb = t(b)
  return aa < bb ? -1 : aa > bb ? 1 : 0
}

//A sorting method for resources in a category. This is not just a predicate
//because we need to traverse the entire list to compute individual sorting
//keys.
export const sortByLogicalOrderAndName = (resources) => {
  const sortingKeysByName = {}
  let sortingKeyForName
  sortingKeyForName = (resName) => {
    const cached = sortingKeysByName[resName]
    if (cached) {
      return cached
    }
    const res = resources.find((res) => res.name == resName)
    const parts = []
    if (res.contained_in) {
      parts.push(sortingKeyForName(res.contained_in))
      parts.push("000") //ensure that `contained_in` resources are sorted before `scales_with` resources
    }
    if (res.scales_with) {
      parts.push(sortingKeyForName(res.scales_with.resource_name))
    }
    parts.push(t(resName))
    const key = parts.join("/")
    sortingKeysByName[resName] = key
    return key
  }

  return resources.sort((resA, resB) => {
    const keyA = sortingKeyForName(resA.name)
    const keyB = sortingKeyForName(resB.name)
    return keyA < keyB ? -1 : keyA > keyB ? 1 : 0
  })
}

//A sorting predicate for categories: Sort by translated name, but categories
//named after their service come first.
export const byNameIn = (serviceType) => (a, b) => {
  if (t(serviceType) == t(a)) {
    return -1
  }
  if (t(serviceType) == t(b)) {
    return +1
  }
  return byUIString(a, b)
}

//Formats large integer numbers for display by adding digit group separators.
export const formatLargeInteger = (value) => {
  //The SI/ISO 31-0 standard recommends to separate each block of three
  //digits by a thin space; Unicode offers the narrow no-break space U+202F
  //for this purpose.
  return Math.round(value)
    .toString()
    .replace(/\B(?=(\d{3})+(?!\d))/g, "\u202F")
  //^ This beautiful regex courtesy of <https://stackoverflow.com/a/2901298/334761>.
}

const participles = {
  Check: "Checking",
  Submit: "Submitting",
  Save: "Saving",
}

//Formats a button caption that can change from infinitive to participle (e.g.
//"Save" -> "Saving...") while an AJAX request is in progress.
export const buttonCaption = (verb, ajaxInProgress) =>
  ajaxInProgress ? (
    <React.Fragment>
      <span className="spinner" /> {participles[verb]}...
    </React.Fragment>
  ) : (
    verb
  )
