import { generateConfig, parseConfig } from "../components/autoscaling/helper"

describe("generate_config", () => {
  it("generates configs that .parse_config accepts", () => {
    for (let value = 0; value < 90; value++) {
      const assetType = "project-quota:foo:bar"
      expect(parseConfig(generateConfig(value, assetType), assetType)).toEqual({
        custom: false,
        value,
        minFree: "project-quota:foo:bar",
      })
    }
  })
})
