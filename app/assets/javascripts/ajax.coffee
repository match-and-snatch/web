# All requests go through bud.Ajax
class bud.Ajax
  @get:  (path, params, callbacks = {}) -> (new bud.Ajax(path, params, callbacks)).get()
  @post: (path, params, callbacks = {}) -> (new bud.Ajax(path, params, callbacks)).post()

  constructor: (path, params = {}, callbacks = {}) ->
    @path      = path
    @params    = params
    @callbacks = callbacks
    @before    = callbacks['before'] || ->
    @after     = callbacks['after'] || ->

  get:  -> @perform_request('GET')
  post: -> @perform_request('POST')

  perform_request: (type) ->
    @options = {}
    @options['beforeSend'] = @before
    @options['type']       = type
    @options['data']       = @params

    $.ajax(@path, @options).done(@on_response_received).fail(@on_bad_response_received).always(@after)

  on_bad_response_received: =>
    bud.Logger.error("Invalid request on #{@path}")

  on_response_received: (response) =>
    if callback = @callbacks[response['status']]
      callback(response)
    else
      switch response['status']
        when 'redirect'
          window.location = response['url'] || window.location
        when 'failed'
          alert(response['message'] || "Invalid request on #{@path}")
        when 'reload'
          window.location.reload()
