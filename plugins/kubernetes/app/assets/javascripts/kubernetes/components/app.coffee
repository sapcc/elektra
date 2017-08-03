# require kubernetes/components/clusters/item

{ div, h4, p, a, ul, li } = React.DOM
{ connect } = ReactRedux
{ Cluster, fetchClusters } = kubernetes

App = React.createClass
  componentDidMount: ->
    @props.loadClusters()

  render: () ->

    div null,
      div className: "bs-callout bs-callout-info bs-callout-emphasize",
        h4 null, "Welcome to our Kubernetes-as-a-Service offering"
        p null, "Affordances responsive minimum viable product co-working ideate co-working user story long shadow agile paradigm quantitative vs. qualitative driven. Paradigm waterfall is so 2000 and late piverate moleskine actionable insight convergence human-centered design affordances actionable insight food-truck."
        ul null,
          li null, "Minimum viable product SpaceTeam parallax pivot"
          li null, "thinker-maker-doer pitch deck latte actionable insight disrupt."
          li null, "Integrate driven paradigm entrepreneur prototype pivot responsive responsive experiential affordances co-working grok."

        p null, "Convergence human-centered design hacker driven user story user centered design Steve Jobs actionable insight bootstrapping experiential engaging user centered design. Entrepreneur minimum viable product user centered design experiential experiential paradigm minimum viable product SpaceTeam latte. Intuitive unicorn actionable insight 360 campaign unicorn workflow hacker sticky note unicorn responsive fund. User story unicorn affordances pivot grok personas parallax pitch deck. Actionable insight engaging pair programming venture capital ship it latte big data innovate sticky note personas driven bootstrapping."

      div null,
        a className: "btn btn-primary", onClick: ((e) -> e.preventDefault(); handleClusterCreate()),
          "Create Cluster"


    # React.createElement ClusterList,
    #   clusters: @props.events,
    #   isFetching: @props.isFetching,
    #   loadClusters: @props.loadClusters



kubernetes.App = connect(
  (state) ->
    clusters:   state.clusters
    isFetching: state.isFetching



  (dispatch) ->
    loadClusters:         () -> dispatch(fetchClusters())
    handleClusterCreate:  () -> dispatch(fetchClusters())
)(App)
