#= require ./ns.js
#= base
beforeHandlers = {}
hash = new ReactiveHash()


Meteor.startup ->
  # Ensure the page router is started.
  page.start()



# Default route to the property is visible to first-time users
# looking at the Router namespace in the console.
# This is set when the route changes.
Router.route = null



###
REACTIVE: Gets or sets the current route.
@param route: The route to set.  Pass nothing to read.
###
Router.current = (route) ->

  # Store [layout] and [tmpl] values ONLY IF they have changed.
  templateChanged = false
  storeIfChanged = (prop, value) ->
          value ?= null
          if value isnt prop()
            templateChanged = true
            prop(value)

  if route
    storeIfChanged(Router.deps.layout, route?.layout )
    storeIfChanged(Router.deps.tmpl, route?.tmpl )

    # Invoke the "anything changed" invalidation.
    Router.invalidate()


  Router.deps.route() # Read from the hash (so as to make this call reactive).
  if templateChanged
    # Store the value causing a reactive callback, only if there is a template change.
    Router.deps.route(route?.pattern)


  # NB: Return the non-serialized version of the route.
  #     (so that the params array is not stripped of properties and
  #      other non-serializable values, like functions, are retained).
  Router.route



###
Configures the router with default options.
@param options
          - tmpl:   The default control template to use if not specified on the route.
          - layout: The default layout template to use if not specified on the route.
###
Router.defaults = (options = {}) ->
  defaults = PKG._defaults
  defaults.tmpl   = options.tmpl   if options.tmpl
  defaults.layout = options.layout if options.layout




###
The complete set of registered route definitions.
###
Router.routes = {}

Router.deps = deps = (value) -> hash.prop 'route',  value   # Invalidates on all changes to route.
deps.route      = (value) -> hash.prop 'route',  value   # Only invalidates when route URL changes.
deps.layout     = (value) -> hash.prop 'layout', value   # Only invaliates when 'layout' changes.
deps.tmpl       = (value) -> hash.prop 'tmpl',   value   # Only invalidates when 'tmpl' changes.


###
Causes any function that are dependent upon [deps]
to be re-run.
###
Router.invalidate = -> Router.deps(+(new Date()))


###
Causes the {{current-route}} and {{yeild}} controls
to be redrawn.
@param options:
          - layout: Flag indicating if the layout should be redrawn,
                    or just the control rendered within the {{yeild}} statement.
                    (default:true)
###
Router.redraw = (options = {}) ->
  # Bump to the reactive-hash object value, causing a redraw.
  bump = (prop) ->
            value = prop()
            prop('')
            prop(value)
  if (options.layout ? true) and Router.deps.layout()?
    bump(Router.deps.layout)
  else
    bump(Router.deps.tmpl)


###
Formats the given path with the base URL.
@param path: The path to format.
@param base: (optional) The base part of the URL.
                        value set via the [base] method is used.
###
Router.formatUrl = (path, base = null) ->
  return path if path is '*'
  path = path.remove(/^\//)
  base = if Object.isString(base) then base.remove(/\/$/) else ''
  "#{ base }/#{ path }"





###
Registers a set of routes.
@param base:    (optional) The base path to prepend all routes with.
@param routes:  A object containing route definitions, eg:
                    {
                      '/foo/:id': (context) -> # Handler to run on load.
                      '/bar':
                          - tmpl:               The control template to use for this route.
                          - layout:             The layout to use for this route
                          - on: (route) ->      Handler to run on load.
                          - title:              Page title ( string or function(route) ).
                          - before: (route) ->  Function (or array of functions) to run before the route is executed.
                    }
###
Router.add = (base, routes) ->
  # Correct parameters if the optional 'base' parameter was not specified.
  routes = base if Util.isObject(base) and not routes?

  # Register each defined route with [page-js].
  for path, def of routes
    def             = { on:def } if Object.isFunction(def)
    path            = Router.formatUrl(path, base)
    def.pattern     = path
    fnHandler       = routeHandler(def)
    Router.routes[path] = def
    page(path, fnHandler)

    # Register "before" handlers.
    if handlers = def.before
      handlers = [handlers] unless Object.isArray(handlers)
      for func in handlers
        Router.before(path, func)



###
Registers a function to run before the given route is displayed.
@param path: The URL path, or '*' to run before all routes.
@param func(route): The function (or array of functions) to be invoked.
###
Router.before = (path, func) ->
  # Check for implicit wildcard (no path specified).
  unless Object.isString(path)
    func = path
    path  = '*'

  # Process function parameter into an array.
  callbacks = if Object.isArray(func) then func else [func]

  # Store the handler.
  handlers = beforeHandlers[path] ?= []
  for func in callbacks
    if Object.isFunction(func)
      handlers.push({ path:path, func:func })


###
Retrieves the set of before handlers (including the '*' wildcard) for the given path.
@param path: The URL path to retrieve handlers for.
###
Router.beforeHandlers = (path) ->
  handlers = beforeHandlers[path] ?= []
  handlers = handlers.clone()
  unless path is '*'
    wildcard = beforeHandlers['*']
    handlers.push(wildcard) if wildcard
  handlers.flatten()



# PRIVATE --------------------------------------------------------------------------



routeHandler = (def) ->
  fn = (context, next) ->
        # Setup initial conditions.
        route = new Router.RouteContext(def, context)
        return if route.runRedirect() # Perform a redirect if required.

        # Run all the handlers for the route, and exit out if a redirection occurred.
        return unless route.run()

        # Store the route.
        Router.route = route  # Non-reactive
        Router.current(route) # Reactive.




