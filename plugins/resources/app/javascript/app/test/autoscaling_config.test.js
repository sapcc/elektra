// `@babel/polyfill` is deprecated
// https://github.com/zloirock/core-js/blob/master/docs/2019-03-19-core-js-3-babel-and-a-look-into-the-future.md#babel
import "core-js/stable";
import "regenerator-runtime/runtime";

import { generateConfig, parseConfig } from '../components/autoscaling/helper';

describe('generate_config', () => {
  it('generates configs that .parse_config accepts', () => {
    for (let value = 0; value < 90; value++) {
      const assetType = 'project-quota:foo:bar';
      expect(parseConfig(generateConfig(value, assetType), assetType)).toEqual({ custom: false, value });
    }
  });
});
