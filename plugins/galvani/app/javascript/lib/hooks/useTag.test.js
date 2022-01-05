import { getServiceParams } from "./useTag"

describe("useTag", () => {
  describe("getServiceParams", () => {
    describe("service without params", () => {
      test("returns params", () => {
        expect(getServiceParams("dns_reader")).toEqual({
          hasVars: false,
          key: "dns_reader",
          name: "dns_reader",
        })
      })
    })
    describe("service with params", () => {
      test("returns params", () => {
        expect(getServiceParams("dns_edit_zone:$1")).toEqual({
          hasVars: true,
          key: "dns_edit_zone:$1",
          name: "dns_edit_zone",
        })
      })
    })
  })
})
