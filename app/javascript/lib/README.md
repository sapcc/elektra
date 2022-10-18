# Ajax Helper

Ajax Helper encapsulates standard behavior for ajax requests. For example, by default the content-type is set to application/json and the x-csrf-token, if present, is set. In addition, the user is automatically redirected to the login screen if the response contains the appropriate location header.

# Usage

```js
import { createAjaxHelper } from "lib/ajax_helper"

const client = createAjaxHelper()

client
  .get("https://api.publicapis.org/entries")
  .then((response) => console.log(response.data))
```

Cancelable

```js
import { createAjaxHelper } from "lib/ajax_helper"

const client = createAjaxHelper()

const { request, cancel } = client.cancelable.get(
  "https://api.publicapis.org/entries"
)

request.then((res) => console.log(res.data))
cancel() // cancel request now
```

## Client

```js
import { createAjaxHelper } from "lib/ajax_helper"
```

###_createAjaxHelper_`(OPTIONS)` -> `Object`

<a name="options"></a>_Available options:_

- `baseURL {String}`
- `headers {Object}` e.g. `{ "Content-Type": "text/html" }`
- `pathPrefix {String}` that is prefixed before each path
- `headerPrefix {String}` that is prefixed before each header key
- `nonPrefixHeaders {Object}` headers to which the headerPrefix is not applied
- `params {Object}` default query parameters
- `timeout {Number}` seconds to timeout a request
- `debug {Boolean}` default is false

## Actions

#### get(url,options) ⇒ promise

```js
// Example
client
  .get("test", { params: { name: "foo" }, headers: { "X-Test": "test" } })
  .then((res) => res.data)
```

#### head(`url_or_path, options`) ⇒ `promise`

```js
// Example
client
  .head("https://test.com")
  .then((response) => console.log(response.headers))
```

#### post(`url_or_path, values, options`) ⇒ `promise`

```js
// Example
client.post("test", { key: "value" }, { baseURL: "https://test.com" })
```

#### put(`url_or_path, values, options`) ⇒ `promise`

```js
// Example
client.put("test", { key: "value" }).then((res) => res.data)
```

#### patch(`url_or_path, values, options`) ⇒ `promise`

```js
// Example
client.patch("test", { key: "value" }).then((res) => res.data)
```

#### copy(`url_or_path, options`) ⇒ `promise`

```js
// Example
client.copy("test", { headers: { "X-TARGET": "test2" } })
```

#### delete(`url_or_path, options`) ⇒ `promise`

```js
// Example
client.delete("users/1")
```

Options: look at [Available options](#options). Action options override client options!!!

## Cancelable

`client.cancelable`

#### get(`url,options`) ⇒ `{ request: promise, cancel: func }`

```js
// Example
client.cancelable
  .get("test", { params: { name: "foo" }, headers: { "X-Test": "test" } })
  .then((res) => res.data)
```

#### head(`url_or_path, options`) ⇒ `{ request: promise, cancel: func }`

```js
// Example
client.cancelable
  .head("https://test.com")
  .then((response) => console.log(response.headers))
```

#### post(`url_or_path, values, options`) ⇒ `{ request: promise, cancel: func }`

```js
// Example
client.cancelable.post(
  "test",
  { key: "value" },
  { baseURL: "https://test.com" }
)
```

#### put(`url_or_path, values, options`) ⇒ `{ request: promise, cancel: func }`

```js
// Example
client.cancelable.put("test", { key: "value" }).then((res) => res.data)
```

#### patch(`url_or_path, values, options`) ⇒ `{ request: promise, cancel: func }`

```js
// Example
client.cancelable.patch("test", { key: "value" }).then((res) => res.data)
```

#### copy(`url_or_path, options`) ⇒ `{ request: promise, cancel: func }`

```js
// Example
client.cancelable.copy("test", { headers: { "X-TARGET": "test2" } })
```

#### delete(`url_or_path, options`) ⇒ `{ request: promise, cancel: func }`

```js
// Example
client.cancelable.delete("users/1")
```

Options: look at [Available options](#options). Action options override client options!!!
