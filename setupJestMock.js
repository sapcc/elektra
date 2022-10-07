/* global jest */
const mockFetchPromise = Promise.resolve({
  json: jest.fn(() => Promise.resolve({ name: "test" })),
  ok: true,
  status: 200,
  statusText: "success",
  headers: { test: "test" },
})

global.fetch = jest.fn(() => mockFetchPromise)
