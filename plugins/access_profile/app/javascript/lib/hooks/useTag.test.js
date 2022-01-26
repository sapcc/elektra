import { getServiceParams, composeTag } from "./useTag"

describe("useTag", () => {
  describe("getServiceParams", () => {
    describe("null service", () => {
      test("returns params", () => {
        expect(getServiceParams(null)).toEqual({
          hasVars: false,
          vars: [],
          key: "",
          name: "",
        })
      })
    })
    describe("empty service", () => {
      test("returns params", () => {
        expect(getServiceParams("")).toEqual({
          hasVars: false,
          vars: [],
          key: "",
          name: "",
        })
      })
    })
    describe("service without params", () => {
      test("returns params", () => {
        expect(getServiceParams("dns_reader")).toEqual({
          hasVars: false,
          vars: [],
          key: "dns_reader",
          name: "dns_reader",
        })
      })
    })
    describe("service with 1 param", () => {
      test("returns params", () => {
        expect(getServiceParams("dns_edit_zone:$1")).toEqual({
          hasVars: true,
          vars: ["$1"],
          key: "dns_edit_zone:$1",
          name: "dns_edit_zone",
        })
      })
    })
    describe("service with more params", () => {
      test("returns params", () => {
        expect(getServiceParams("dns_edit_zone:$1:$2")).toEqual({
          hasVars: true,
          vars: ["$1", "$2"],
          key: "dns_edit_zone:$1:$2",
          name: "dns_edit_zone",
        })
      })
    })
  })
  describe("composeTag", () => {
    describe("tag without params", () => {
      test("returns tag", () => {
        expect(
          composeTag({
            profile: "internet",
            service: { value: "dns_reader" },
            attrs: [],
          })
        ).toEqual("xs:internet:dns_reader")
      })
    })
    describe("tag with params", () => {
      test("returns tag", () => {
        expect(
          composeTag({
            profile: "internet",
            service: { value: "dns_edit_zone" },
            attrs: { $1: "arturo" },
          })
        ).toEqual("xs:internet:dns_edit_zone:arturo")
      })
    })
  })
})
