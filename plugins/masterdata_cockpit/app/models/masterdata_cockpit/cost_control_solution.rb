module MasterdataCockpit
  class CostControlSolution < Core::ServiceLayer::Model
    # the following attributes ar known
    #"solution_name": "mySolution",
    #"cost_objects": [
    #    {
    #        "solution_name":"myProductiveCo",
    #        "type":"CC",
    #        "revenue_relevance":"generating"
    #    },
    #    {
    #        "solution_name":"myTestingCo",
    #        "type":"CC",
    #        "revenue_relevance":"enabling"
    #    }
    #]
    
    def name
      read('solution_name')
    end
  end
end