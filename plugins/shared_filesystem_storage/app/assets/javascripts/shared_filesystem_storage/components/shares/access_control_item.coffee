{ tr,td,button,i } = React.DOM

shared_filesystem_storage.AccessControlItem = ({handleDelete, rule}) ->
  humanizeAccessLevel = switch rule.access_level
    when 'ro' then 'read only'
    when 'rw' then 'read/write'
    else rule.access_level

  tr className: ('updating' if rule.isDeleting),
    td null, rule.access_type
    td null, rule.access_to
    td className: "#{if rule.access_level == 'rw' then 'text-success' else 'text-info'}",
      i className: "fa fa-fw fa-#{if rule.access_level == 'rw' then 'pencil-square' else 'eye'}"
      humanizeAccessLevel
    td null, rule.state
    td className: 'snug',
      button className: 'btn btn-danger btn-sm', onClick: ((e) -> e.preventDefault(); handleDelete(rule.id)),
        i className: 'fa fa-minus'
