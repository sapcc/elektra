const bases = {
  '':  { scale: 'none' }, // countable things
  'B': { scale: 'iec'  }, // bytes (B, KiB, MiB, etc.)
};
const scales = {
  'none': {
    step: 1,
    prefixes: [''],
  },
  'iec': {
    step: 1024,
    prefixes: [ '', 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei' ],
  },
};

const units = Object.fromEntries(
  Object.entries(bases).flatMap(([base, props]) =>
    scales[props.scale].prefixes.map((prefix, idx) => [
      prefix + base,
      { base, steps: idx },
    ])
  )
);

export class Unit {
  constructor(name) {
    this.name = name || '';
    this.unitData = units[this.name] || { base: name, steps: 0 };
    const baseData = bases[this.unitData.base] || { scale: 'none' };
    this.scaleData = scales[baseData.scale];
  }

  //Formats a value in this unit. May use bigger units for big values. For
  //example:
  //
  //    Unit('MiB').format(10)    => '10 MiB'
  //    Unit('MiB').format(10240) => '10 GiB'
  //
  format(value) {
    //convert value into bigger units if available
    let steps = this.unitData.steps;
    while (value > this.scaleData.step && steps + 1 < this.scaleData.prefixes.length) {
      value /= this.scaleData.step;
      steps += 1;
    }
    const displayUnit = this.scaleData.prefixes[steps] + this.unitData.base;

    //round value down to 3 digits if we have a fractional value
    if (value > 100) {
      value = Math.round(value);
    } else if (value > 10) {
      value = Math.round(value * 10) / 10;
    } else {
      value = Math.round(value * 100) / 100;
    }

    return `${value} ${displayUnit}`;
  }
}
