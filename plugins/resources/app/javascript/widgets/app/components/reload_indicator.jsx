const ReloadIndicator = ({ children, isReloading }) => {
  return (
    <div className={isReloading ? 'block-on-reload is-reloading' : 'block-on-reload'}>
      {children}
      <div className='reload-message'><span className='spinner' /> Reloading...</div>
    </div>
  );
};

export default ReloadIndicator;
