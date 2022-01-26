Template Creation:
Subject: Preferences for {{ name.firstName }}
```html
  <!doctype html>
  <html>
    <head><meta charset="utf-8"></head>
    <body>
      <h1>Your Preferences</h1>
      <h2>Dear {{ name.lastName }}, </h2>
      <p>
        You have indicated that you are interested in receiving information about the following topics:
      </p>
      <ul>
        {{#each subscription}}
          <li>{{interest}}</li>
        {{/each}}
      </ul>
      <p>
        You can change these settings at any time by visiting 
        the <a href=https://www.abc.xyz/preferences/i.aspx?id={{meta.userId}}>
        Preference Center</a>.
      </p>
    </body>
  </html> 
```
Template Data:

```json
  {
    "meta":{
      "userId":"575132908"
    },
    "contact":{
      "firstName":"Michael",
      "lastName":"Jackson",
      "city":"Texas",
      "country":"USA",
      "postalCode":"78974"
    },
    "subscription":[
      {
        "interest":"Sports"
      },
      {
        "interest":"Travel"
      },
      {
        "interest":"Cooking"
      }
    ]
  }
```
