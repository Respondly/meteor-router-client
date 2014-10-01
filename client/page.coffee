###
Loads the given URL into the browser, adding it to the history.

@param path: The URL to load.
@param options:
          - force: Flag indicating if the URL should be loaded even if the existing
                   url is either the same, or an ancestor of the current URL.
                   (default:true)

                    Example when force==false:

                        Current URL path:  /root/foo/bar
                        New URL path:      /root/foo

                    The new URL would not be loaded.

@returns true if the URL was loaded, of false if the non-forced load operation decided the URL should not be loaded.
###
Router.show = (path, options) -> load path, options, (url) -> page.show(url)


###
Replaces the given URL into the browser, NOT adding it to the history.

@param path: The URL to load.
@param options:
          - force: Flag indicating if the URL should be loaded even if the existing
                   url is either the same, or an ancestor of the current URL.
                   (default:true)

                    Example when force==false:

                        Current URL path:  /root/foo/bar
                        New URL path:      /root/foo

                    The new URL would not be loaded.

@returns true if the URL was loaded, of false if the non-forced load operation decided the URL should not be loaded.
###
Router.replace = (path, options) -> load path, options, (url) -> page.replace(url)




# PRIVATE --------------------------------------------------------------------------



load = (path, options = {}, fnLoad) ->
  force  = options.force ? true

  # Exit out if this is a non-forced URL load operation and there
  # is ancestor match.
  if not force
    if isAncestorOfCurrent(path) or isDifferentQueryStringFromCurrent(path)
      return false

  # Load the URL.
  fnLoad(path)

  # Finish up.
  true


isAncestorOfCurrent = (path) -> Router.route.path.startsWith(path)


isDifferentQueryStringFromCurrent = (path) ->
  if queryString = path.split('?')[1]
    queryString ?= ''
    Route.route.queryString isnt queryString
  else
    false


