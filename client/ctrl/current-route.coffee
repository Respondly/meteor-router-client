toHtml = (type) ->
  if type
    route = Router.route
    result =
      type: type
      data: route?.data


# ----------------------------------------------------------------------


Ctrl.define
  'current-route':
    helpers:
      hasLayout:  -> Router.deps.layout()?
      layoutHtml: -> toHtml(Router.deps.layout())
      tmplHtml:   -> toHtml(Router.deps.tmpl())



  'yield':
    helpers:
      html: -> toHtml(Router.deps.tmpl())


