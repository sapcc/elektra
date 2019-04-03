import 'babel-polyfill';
import { Unit } from '../unit';

describe('Unit', () => {

  describe('.render', () => {

    it('renders number values as plain numbers', () => {
      const u = new Unit('');
      expect(u.format(0)).toEqual('0')
      expect(u.format(42)).toEqual('42')
      expect(u.format(123)).toEqual('123')
      expect(u.format(1234567)).toEqual('1234567')
    })

    it('renders byte values with appropriate units', () => {
      const cases = [
        [ 42,            /^42\sB$/     ],
        [ 1000,          /^1000\sB$/   ],
        [ 1024,          /^1\sKiB$/    ],
        [ 1234567,       /^1.18\sMiB$/ ],
        [ 1234567890,    /^1.15\sGiB$/ ],
        [ 45421255555,   /^42.3\sGiB$/ ],
        [ 1234567890123, /^1.12\sTiB$/ ],
      ]
      const u = new Unit('B');
      for (const [ input, output ] of cases) {
        expect(u.format(input)).toMatch(output)
      }
    })

    it('renders mega-byte values with appropriate units', () => {
      const cases = [
        [ 1,       /^1\sMiB$/     ],
        [ 1234,    /^1.21\sGiB$/  ],
        [ 45421,   /^44.36\sGiB$/ ],
        [ 1234567, /^1.18\sTiB$/  ],
      ]
      const u = new Unit('MiB');
      for (const [ input, output ] of cases) {
        expect(u.format(input)).toMatch(output)
      }
    })

  })

  describe('.parse', () => {
    const errSyntax = { error: 'syntax' };
    const errFractional = { error: 'fractional-value' };

    it('accepts non-negative integers only for data type number', () => {
      const u = new Unit("")

      expect(u.parse("52")).toEqual(52)
      expect(u.parse("0")).toEqual(0)
      expect(u.parse("1234567890")).toEqual(1234567890)

      expect(u.parse("    0004  ")).toEqual(4)

      expect(u.parse("4.2")).toEqual(errFractional)
      expect(u.parse("4,2")).toEqual(errFractional)
      expect(u.parse("foo")).toEqual(errSyntax)
      expect(u.parse("4 things")).toEqual(errSyntax)
      expect(u.parse("4 GiB")).toEqual(errSyntax)
    })

    const inflateTestCases = (cases) => {
      //check multiple representations of the same input
      const onlyUnique = (val, idx, array) => array.indexOf(val) === idx;
      //1. with comma or dot
      cases = cases.flatMap(([ str, num ]) => ([
        [ str, num ],
        [ str.replace(/\./, ','), num ],
      ].filter(onlyUnique)));
      //2. with space between value and unit removed
      cases = cases.flatMap(([ str, num ]) => ([
        [ str, num ],
        [ str.replace(/\s+/g, ''), num ],
      ].filter(onlyUnique)));
      //3. with extra surrounding space
      cases = cases.flatMap(([ str, num ]) => ([
        [ str, num ],
        [ `  ${str}\n`, num ],
      ].filter(onlyUnique)));
      //4. with units like "KiB" shortened to "KB" or "K"
      cases = cases.flatMap(([ str, num ]) => ([
        [ str, num ],
        [ str.replace("iB", "B"), num ],
        [ str.replace("iB", ""), num ],
      ].filter(onlyUnique)));
      //5. with units in all lowercase or all uppercase
      cases = cases.flatMap(([ str, num ]) => ([
        [ str, num ],
        [ str.toLowerCase(), num ],
        [ str.toUpperCase(), num ],
      ].filter(onlyUnique)));

      return cases;
    };

    it('parses byte values correctly', () => {
      let cases = [
        [ "0 B",      0 ],
        [ "42 B",     42 ],
        [ "1000 B",   1000 ],
        [ "1 KiB",    1024 ],
        [ "1.18 MiB", 1237319 ],
        [ "1.15 GiB", 1234803097 ],
        [ "42.3 GiB", 45419279155 ],
        [ "1.12 TiB", 1231453023109 ],
      ]

      const u = new Unit("B");
      for (const [str, num] of inflateTestCases(cases)) {
        expect(u.parse(str)).toEqual(num);
      }

      expect(u.parse('foo')).toEqual(errSyntax);
      expect(u.parse('4 things')).toEqual(errSyntax);
    })

    it('parses mega-byte values correctly', () => {
      let cases = [
        [ "0 MiB",      0 ],
        [ "1048576 B",  1 ],
        [ "1.21 GiB",   1239 ],
        [ "44.61 GiB",  45680 ],
        [ "1.177 TiB",  1234173 ],
      ]

      const u = new Unit("MiB");
      for (const [str, num] of inflateTestCases(cases)) {
        expect(u.parse(str)).toEqual(num);
      }

      expect(u.parse('16 mk')).toEqual(errSyntax);
      expect(u.parse('8 k')).toEqual(errFractional);
      expect(u.parse('4 b')).toEqual(errFractional);
    })

    it('rejects byte values without explicit unit', () => {
      const units = [ new Unit("B"), new Unit("MiB") ];
      for (const u of units) {
        expect(u.parse("0")).toEqual(errSyntax);
        expect(u.parse("42")).toEqual(errSyntax);
      }
    })

  })

})
