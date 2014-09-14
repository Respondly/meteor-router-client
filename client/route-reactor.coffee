###
Base class for monitoring changes in routes.
###
class Router.RouteReactor extends AutoRun
  constructor: ->
    super
    @hash = new ReactiveHash()
    @hash.onlyOnChange = true # Prevent reactive callbacks when properties are written to with an existing value.

    # Update routes when the route changes.
    @autorun =>
      Router.current() # Hook into reactive callback.
      @invalidate()

    # Force an update to the routes when the app has finished being initialized.
    @autorun =>
      if APP?.isInitialized() is true
        @invalidate(force:true)


  dispose: -> super


  ###
  Causes the updateRoutes method to be re-run.
  @param options
          - force: Flag indicating if the update method should be forced
                   to run even if the URL has not changed.
  ###
  invalidate: (options = {}) ->
    Deps.nonreactive =>
      # Setup initial conditions.
      route = Router.current()
      return unless route?
      force = options.force ? false

      # Supress repeat callbacks when then URL has not changed.
      return if @_lastUrl is route.fullPath and not force

      # Update teh URL.
      @updateRoutes(route)
      @_lastUrl = route.fullPath



  updateRoutes: (route) ->
    # Use the [x ? null] pattern below to convert undefined values to null
    # to ensure set occurs rather than get.
    @pattern     route.pattern ? null
    @path        route.path ? null
    @queryString route.query?.toString() ? ''


  prop: (key, value, options = {}) -> @hash.prop(key, value, options)


  path:         (value) -> @prop('path', value)
  pattern:      (value) -> @prop('pattern', value)
  queryString:  (value) -> @prop('queryString', value)

