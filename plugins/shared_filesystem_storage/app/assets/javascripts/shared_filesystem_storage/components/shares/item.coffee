{ tr,td,br,span,div,button,ul,li,a ,i,small} = React.DOM

ShareItem = React.createClass
  componentWillReceiveProps: (nextProps) ->
    # stop polling if status has changed from creating to something else
    @stopPolling() unless nextProps.share.status=='creating'

  componentDidMount:()->
    @startPolling() if @props.share.status=='creating'

  componentWillUnmount: () ->
    # stop polling on unmounting
    @stopPolling()

  startPolling: ()->
    @polling = setInterval((() => @props.reloadShare(@props.share.id)), 1000)

  stopPolling: () ->
    clearInterval(@polling)

  render: ->
    {share,shareNetwork,shareRules,handleShow,handleDelete,handleEdit,handleSnapshot,handleAccessControl} = @props

    tr {className: ('updating' if share.isDeleting)},
      td null,
        a href: '#', onClick: ((e) -> e.preventDefault(); handleShow(share.id)), share.name || share.id
      td null, share.share_proto
      td null, (share.size || 0) + ' GB'
      td null, (if share.is_public then 'public' else 'private')
      td null,
        if share.status=='creating'
          span className: 'spinner'
        share.status
      td null,
        if shareNetwork
          span null,
            shareNetwork.name
            span className: 'info-text', " "+shareNetwork.cidr
            if shareRules
              if shareRules=='loading'
                span className: 'spinner'
              else
                span null,
                  br null
                  for rule in shareRules.items
                    small key: rule.id,
                    "data-toggle": "tooltip",  "data-placement": "right",
                    title: "Access Level: #{if rule.access_level=='ro' then 'read only' else if 'rw' then 'read/write' else rule.access_level}",
                    className: "#{if rule.access_level == 'rw' then 'text-success' else 'text-info'}",
                    ref: ((el) ->$(el).tooltip()),

                      i className: "fa fa-fw fa-#{if rule.access_level == 'rw' then 'pencil-square' else 'eye'}"
                      rule.access_to
        else
          span className: 'spinner'

      td { className: "snug" },
        if share.permissions.delete or share.permissions.update
          div { className: 'btn-group' },
            button { className: 'btn btn-default btn-sm dropdown-toggle', type: 'button', 'data-toggle': 'dropdown', 'aria-expanded': true},
              span {className: 'fa fa-cog' }

            ul { className: 'dropdown-menu dropdown-menu-right', role: "menu" },
              if share.permissions.delete
                li null,
                  a { href: '#', onClick: ((e) -> e.preventDefault(); handleDelete(share.id))}, 'Delete'
              if share.permissions.update
                li null,
                  a { href: '#', onClick: ((e) -> e.preventDefault(); handleEdit(share)) }, 'Edit'
              if share.permissions.update and share.status=='available'
                li null,
                  a { href: '#', onClick: ((e) -> e.preventDefault(); handleSnapshot(share.id)) }, 'Create Snapshot'

              if share.permissions.update and share.status=='available'
                li null,
                  a { href: '#', onClick: ((e) -> e.preventDefault(); handleAccessControl(share.id,share.share_network_id)) }, 'Access Control'

shared_filesystem_storage.ShareItem = ShareItem
