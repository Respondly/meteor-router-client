###
Represents a current route.
###
class Router.RouteContext
  constructor: (@def, @_context) -> @revert()
  parentUrl: -> @toUrl().parent()


  ###
  Converts the route into a [Url] object.
  @param pattern: (optional)  An alternative URL pattern to parse parameters with.
                              If not specified the route's defined pattern is used.
  ###
  toUrl: (pattern) ->
    pattern ?= @pattern
    new Url(@fullPath, pattern)


  ###
  Reverts the route-context back to it's original state.
  ###
  revert: ->
    # Setup initial conditions.
    context       = @_context
    defaults      = PKG._defaults
    wasChanged    = @changed?

    # Store values.
    @pattern      = @def.pattern
    @fullPath     = context.path
    @path         = context.path.split('?')[0]
    @params       = context.params
    @redirect     = @def.redirect
    @queryString  = context.querystring ? ''
    @query        = new QueryString(@queryString)

    # Copy values.
    copy = (attr) =>
              value = Util.asValue(@def[attr])
              if value then @[attr] = value else delete @[attr]
    copy 'tmpl'
    copy 'layout'
    copy 'data'

    # Update with default template values (if required).
    @layout ?= defaults.layout if defaults.layout
    @tmpl   ?= defaults.tmpl   if defaults.tmpl

    # Finish up.
    delete @changed
    delete @stopped
    wasChanged


  ###
  Signals that further filters/handlers should not be run on this route.
  ###
  stop: (invalidate = true) ->
    @stopped = true
    @invalidate() if invalidate



  ###
  Runs all handlers for the route, in the following order:

    - global "before" handlers.
    - route specific "before" handlers.
    - the route's [on] handler.

  @param options:
            - exclude: (optional) any functions(s) to exclude from being run.
                        This is useful to avoid circular loops when calling 'run'
                        from within a handler.

  @returns [true] if all handlers ran, or [false] if the a redirection occurred.
  ###
  run: (options = {}) ->
    # Run global "before" handlers.
    funcs = Router.beforeHandlers(@pattern).map (item) -> item.func
    return false unless @runHandlers(funcs, options)

    # Run route-specific "before" handlers.
    return false unless @runHandlers(@before, options)

    # Run the rotues [on] handler
    unless @stopped
      return false unless @runHandlers(@def.on, options)

    # Finish up.
    true


  ###
  Invokes the given handler functions.
  @param handlers: An array of handlers.
  @param options:
            - exclude: (optional) any functions(s) to exclude from being run.
                        This is useful to avoid circular loops when calling 'run'
                        from within a handler.
  @returns [true] if all handlers ran, or [false] if the a redirection occurred.
  ###
  runHandlers: (handlers, options = {}) ->
    # Setup initial conditions.
    exclude     = options.exclude ? []
    exclude     = [ exclude ] unless Object.isArray(exclude)
    isExcluded  = (func) -> exclude.any (item) -> item is func

    # Invoke the handlers.
    if handlers
      handlers = [ handlers ] unless Object.isArray(handlers)
      for func in handlers
        unless isExcluded(func)
          invokeHandler(@, func)
          return false if @runRedirect() # Redirect if one of the handlers setup a redirection.

    # Finish up.
    true


  ###
  Sets a redirect on the route.
  @param path: The URL path to redirect to.
  ###
  redirectTo: (path, options = {}) ->
    unless @fullPath is path
      @stop()
      @redirect = path
      @runRedirect()


  ###
  Invokes a redirection if one is declared on the route.
  @returns true if a redirection occurred, otherwise false.
  ###
  runRedirect: ->
    return false unless @redirect
    path = Util.asValue(@redirect)
    Deps.afterFlush =>
      # NOTE: The "replace" methods uses [history.replaceState] so that a
      #       redundant URL is not included in the browser's "back button" history.
      Router.replace(path)
    true


  ###
  Forces an invalidation of all listeners to [Router.deps()].
  ###
  invalidate: -> Router.invalidate()




# PRIVATE --------------------------------------------------------------------------


invokeHandlers = (route, handlers) ->
  return if route.stopped
  if handlers
    handlers = [handlers] unless Object.isArray(handlers)
    invokeHandler(route, func) for func in handlers


invokeHandler = (route, func) ->
  # Setup initial conditions.
  return false if route.stopped
  return unless Object.isFunction(func)

  # Store original template values for change comparison.
  originalLayout = route.layout
  originalTmpl   = route.tmpl

  # Invoke the handler.
  result = func(route)
  unless route.redirect
    if Util.isObject(result)
      if result.redirect
        # Handle rediection.
        if result.redirect isnt route.fullPath and result.redirect isnt window.location.pathname # Prevent a redirection loop if already on the given path.
          route.redirect = result.redirect

      if result.tmpl
        route.tmpl = result.tmpl

  # Mark the route as 'changed' if any of the templates were
  # updated by the handler.
  if route.layout isnt originalLayout or route.tmpl isnt originalTmpl
    route.changed =
      layout: originalLayout
      tmpl:   originalTmpl

  # Finish up.
  true




