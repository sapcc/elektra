/* global jest */
const mockFetchPromise = Promise.resolve({
  json: jest.fn(() => Promise.resolve({ name: "test" })),
  ok: true,
  status: 200,
  statusText: "success",
  headers: new Headers({
    test: "test",
    "Content-Type": "application/json; charset=utf-8",
  }),
})

global.fetch = jest.fn(() => mockFetchPromise)
