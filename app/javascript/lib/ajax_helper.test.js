delete window.location

window.location = {
  pathname: "/monsoon3/cc-demo/object-storage-ng/containers",
}

const createRequest = () => ({
  open: jest.fn((method, path, rest) =>
    console.log("===open", method, path, rest)
  ),
  send: jest.fn((a, b, c) => console.log("===send", a, b, c)),
  setRequestHeader: jest.fn((a, b, c) =>
    console.log("===set headers", a, b, c)
  ),
})

// use require instead of import because of the window object.
// we want to mock this object before loading the ajax helper
// imports are automatically moved to the top by js.
const {
  scope,
  ajaxHelper,
  configureAjaxHelper,
  pluginAjaxHelper,
  createAjaxHelper,
} = require("./ajax_helper")

const clientMethods = (client, baseURL) => {
  describe(`client methods ${baseURL}`, () => {
    let request = null

    beforeEach(() => {
      request = createRequest()
      window.XMLHttpRequest = jest.fn(() => request)
    })

    expect(client).toBeDefined()

    describe("GET", () => {
      test("should be defined", () => {
        expect(client.get).toBeDefined()
      })
      test("request without options", async () => {
        client.get("test")
        client.get("test")
        expect(request.open).toHaveBeenCalled()
        // expect(open).toHaveBeenCalledWith(
        //   "GET",
        //   baseURL + "test",
        //   expect.anything()
        // )
      })
    })
    describe("POST", () => {
      test("should be defined", () => {
        expect(client.post).toBeDefined()
      })
    })
    describe("PUT", () => {
      test("should be defined", () => {
        expect(client.put).toBeDefined()
      })
    })
    describe("HEAD", () => {
      test("should be defined", () => {
        expect(client.head).toBeDefined()
      })
    })
    describe("PATCH", () => {
      test("should be defined", () => {
        expect(client.patch).toBeDefined()
      })
    })
    // describe("COPY", () => {
    //   test("should be defined", () => {
    //     expect(client.copy).toBeDefined()
    //   })
    // })
    describe("DELETE", () => {
      test("should be defined", () => {
        expect(client.delete).toBeDefined()
      })
    })
  })
}

describe("Ajax Helper", () => {
  describe("scope", () => {
    it("should be defined", () => {
      expect(scope).toBeDefined()
    })
    it("should resolve current scoped domain", () => {
      expect(scope.domain).toEqual("monsoon3")
    })

    it("should resolve current scoped project", () => {
      expect(scope.project).toEqual("cc-demo")
    })
  })

  describe("createAjaxHelper", () => {
    let client = createAjaxHelper()

    it("should be defined", () => {
      expect(createAjaxHelper).toBeDefined()
    })

    clientMethods(client, "")
    // clientMethods(
    //   createAjaxHelper().osApi("object-store"),
    //   "os-api/object-store/"
    // )
  })
})
