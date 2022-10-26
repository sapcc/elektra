/* global jest */
const data = { name: "test" }

const mockFetchPromise = Promise.resolve({
  json: jest.fn(() => Promise.resolve({ name: "test" })),
  blob: jest.fn(() => {
    const blob = new Blob([JSON.stringify(data)], {
      type: "application/json",
    })
    blob.text = jest.fn().mockResolvedValue(JSON.stringify(data))
    return Promise.resolve(blob)
  }),
  text: jest.fn().mockResolvedValue(JSON.stringify(data)),
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
