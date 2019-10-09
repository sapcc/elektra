import '@babel/polyfill';
import { generateConfig, parseConfig } from '../components/autoscaling/config_item';

describe('generate_config', () => {
  it('generates configs that .parse_config accepts', () => {
    for (let value = 0; value < 90; value++) {
      expect(parseConfig(generateConfig(value))).toEqual({ custom: false, value });
    }
  });
});
