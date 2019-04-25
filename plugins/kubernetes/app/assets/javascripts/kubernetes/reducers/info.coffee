((app) ->
    ########################## CLUSTER FORM ###########################
    initialInfoState = 
        availableClusterVersions: []
        defaultClusterVersion: ""
        gitVersion: ""
        supportedClusterVersions: []
        loaded: false
        error: null
        isFetching: false


    requestInfo = (state,{}) ->
        ReactHelpers.mergeObjects({},state,{
            isFetching: true
            error: null
        })

    requestInfoFailure = (state,{error})->
        oldErrorCount = state.errorCount || 0
        ReactHelpers.mergeObjects({},state,{
            isFetching: false
            error: error
            errorCount: oldErrorCount + 1
        })

    receiveInfo = (state, {info}) ->
        ReactHelpers.mergeObjects({},info,{
            isFetching: false
            error: null
            loaded: true
        })


    app.info = (state = initialInfoState, action) ->
        switch action.type
            when app.REQUEST_INFO           then requestInfo(state,action)
            when app.REQUEST_INFO_FAILURE   then requestInfoFailure(state,action)
            when app.RECEIVE_INFO           then receiveInfo(state,action)
            else state

)(kubernetes)
