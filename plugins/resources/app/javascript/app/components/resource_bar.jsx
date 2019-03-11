import { Scope } from '../scope';
import { Unit } from '../unit';

const valueWithUnit = (value, unit) => {
  const title = unit.name !== '' ? `${value} ${unit.name}` : undefined;
  return <span className='value-with-unit' title={title}>{unit.format(value)}</span>;
};

//NOTE: `capacity` and `fill` are generic names. What they actually stand for is
//defined where this component gets used.
const ResourceBar = ({capacity, fill, unitName, isDanger, isEditing, scopeData}) => {
  const scope = new Scope(scopeData);
  const unit = new Unit(unitName || "");

  //get some edge cases out of the way first
  if (capacity == 0 && fill == 0) {
    return (
      <div className='progress'>
        <div className='progress-bar progress-bar-disabled has-label' style={{width:'100%'}}>
          {scope.isCluster() ? "No capacity" : "No quota" }
        </div>
      </div>
    );
  }

  let widthPerc = Math.round(1000 * (fill / capacity)) / 10;
  //ensure that a non-zero-wide bar is at least somewhat visible
  if (fill > 0 && widthPerc < 0.5) {
    widthPerc = 0.5;
  }

  //special cases: yellow and red bars
  let className = 'progress-bar';
  if (isDanger) {
    className = 'progress-bar progress-bar-danger progress-bar-striped';
  } else if (fill >= capacity) {
    className = 'progress-bar progress-bar-warning';
  }
  if (widthPerc > 100) {
    widthPerc = 100;
  }

  //when the label does not fit in the bar itself, place it next to it (we take `isEditing` into account here because then the bar's length is only 60% of the original)
  const label = (
    <React.Fragment>
      {valueWithUnit(fill, unit)}/{valueWithUnit(capacity, unit)}
    </React.Fragment>
  );
  const labelText = `${unit.format(fill)}/${unit.format(capacity)}`;
  const lengthMultiplier = isEditing ? 3.5 : 2;
  if (widthPerc > (lengthMultiplier * labelText.length)) {
    return (
      <div className='progress'>
        <div className={`${className} has-label`} style={{width:widthPerc+'%'}}>
          {label}
        </div>
      </div>
    );
  } else {
    return <div className='progress'>
      <div className={className} style={{width:widthPerc+'%'}} />
      <div className='progress-bar progress-bar-empty has-label'>{label}</div>
    </div>;
  }
};

export default ResourceBar;
