if (!window.policyConfig)
  throw "Missing data. Please provide window.policyConfig"
if (!window.policyConfig.rules)
  throw "Missing rules. Please provide window.policyConfig.rules"
if (!window.policyConfig.locals)
  throw "Missing locals. Please provide window.policyConfig.locals"

// evaluate rules
const rules = {}
for (let name in window.policyConfig.rules) {
  const rule = window.policyConfig.rules[name]
  try {
    rules[name] = eval(rule)
  } catch (e) {
    console.info("Policy Engine Error: ", e)
  }
}

window.policy = {
  isAllowed: function (name, params = {}) {
    const rule = rules[name]
    if (!rule) throw "Policy Engine Error: rule #{name} not found."
    return rule(rules, window.policyConfig.locals, params)
  },
}
