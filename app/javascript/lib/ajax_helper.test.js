delete window.location

window.location = {
  pathname: "/monsoon3/cc-demo/object-storage-ng/containers",
}

window.fetch = jest.fn((url, config) => {
  console.log("===URL", url)
  console.log("===", config)
})
// const request = {
//   open: jest.fn((method, path, rest) =>
//     console.log("===open", method, path, rest)
//   ),
//   send: jest.fn((a, b, c) => console.log("===send", a, b, c)),
//   setRequestHeader: jest.fn((a, b, c) => console.log("===set header", a, b, c)),
// }

// let open = jest.fn((...props) => console.log("====================", props)),
//   send = jest.fn(),
//   setRequestHeader = jest.fn()
// const xhrMockClass = () => ({ open, send, setRequestHeader })
// window.XMLHttpRequest = jest.fn(xhrMockClass)

// use require instead of import because of the window object.
// we want to mock this object before loading the ajax helper
// imports are automatically moved to the top by js.
let {
  scope,
  ajaxHelper,
  configureAjaxHelper,
  pluginAjaxHelper,
  createAjaxHelper,
} = require("./ajax_helper")

const clientMethods = (client, baseURL) => {
  describe(`client methods ${baseURL}`, () => {
    describe("GET", () => {
      test("should be defined", () => {
        expect(client.get).toBeDefined()
      })
      test("request without options", async () => {
        //axios.create().get("test")
        // expect(interceptor).toHaveBeenCalledWith(
        //   expect.objectContaining({ config: { method: "get" } })
        // )
        // expect(client.interceptors.request.use((config) => {).toHaveBeenCalledWith(
        //   "GET",
        //   baseURL + "test",
        //   expect.anything()
        //
      })
    })
    describe("POST", () => {
      test("should be defined", () => {
        expect(client.post).toBeDefined()
      })

      describe("x-csrf-token", () => {
        beforeEach(() => {
          const meta = document.createElement("meta")
          meta.setAttribute("name", "csrf-token")
          meta.setAttribute("content", "CSRF-TOKEN")
          document.head.append(meta)
        })
        it("sends a x-csrf-token header", () => {
          client.post("test", { name: "test" })
          expect(fetch).toHaveBeenCalledWith("test", {
            headers: { "x-csrf-token": "TEST-TOKEN" },
            method: "POST",
          })
        })
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
  describe("ajaxHelper", () => {
    it("should be defined", () => {
      configureAjaxHelper({})
      ajaxHelper = require("./ajax_helper")
      expect(ajaxHelper).toBeDefined()
    })
  })

  describe("configureAjaxHelper", () => {
    it("should be defined", () => {
      expect(configureAjaxHelper).toBeDefined()
    })
    it("should be a function", () => {
      expect(typeof configureAjaxHelper).toEqual("function")
    })
  })

  describe("pluginAjaxHelper", () => {
    it("should be defined", () => {
      expect(pluginAjaxHelper).toBeDefined()
    })
    it("should be a function", () => {
      expect(typeof pluginAjaxHelper).toEqual("function")
    })
  })

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
    it("should be defined", () => {
      expect(createAjaxHelper).toBeDefined()
    })

    clientMethods(createAjaxHelper(), "")
    clientMethods(
      createAjaxHelper().osApi("object-store"),
      "os-api/object-store/"
    )
  })
})
