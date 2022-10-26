/* global jest */
const mockFetchPromise = Promise.resolve({
  json: jest.fn(() => Promise.resolve({ name: "test" })),
  blob: jest.fn(() =>
    Promise.resolve(new Blob([JSON.stringify({ name: "test" }, null, 2)]), {
      type: "application/json",
    })
  ),
  text: jest.fn(() => Promise.resolve("test")),
  formData: jest.fn(() => Promise.resolve(new FormData())),
  ok: true,
  status: 200,
  statusText: "success",
  headers: new Headers({
    test: "test",
    "Content-Type": "application/json; charset=utf-8",
  }),
})

global.fetch = jest.fn(() => mockFetchPromise)
