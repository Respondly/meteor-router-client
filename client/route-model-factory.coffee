###
A factory that reactive looks up a model based on on the current route.
For example:

  /things/:id

Where [:id] is the ID of the model to look up.  Every time the route changes
a new model will be retrieved.  Subsequence calls to [get], when the route has
not changed, retrieves a cached version of the model.
###
class Router.RouteModelFactory
  ###
  Constructor
  @param urlPattern: The base URL to consider.
  ###
  constructor: (@urlPattern) ->



  ###
  Flag indicating whether models are cached.
  ###
  caching: false



  ###
  Reactively looks up the ID from the current route.
  ###
  id: ->
    route = Router.current() # Reactive.
    route.params.id if route?.pattern is @urlPattern


  ###
  Gets the model based on the current route (cached).
  ###
  get: ->
    if id = @id()
      if @caching and @_model?.id is id
        return @_model # From cache.
      else
        return @_model = @create(id) # New instance.



  ###
  Creates a new instance of the mode.
  ###
  create: (id) -> throw new Error('Override this method.')
