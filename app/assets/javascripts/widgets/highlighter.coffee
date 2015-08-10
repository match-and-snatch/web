class bud.widgets.Highlighter extends bud.Widget
  @SELECTOR: '.Highlighter'

  initialize: ->
    @$textarea   = bud.get(@$container.data('target'))
    @$users_list = bud.get(@$container.data('target_list'))
    @profile_id = @data('profile_id')

    unless bud.is_mobile.Android()
      @$textarea.on 'keydown', @on_keydown
      @$textarea.on 'keyup', @on_keyup

    @mentions = []
    @mentions_data = {}

    @update_dimentions()

    @$textarea.focus @on_focus
    @$textarea.click @disable_mentions

    bud.sub('highlighter.changed', @highlighter_changed)

  destroy: ->
    bud.unsub('highlighter.changed', @highlighter_changed)
    bud.unsub('mention.clicked', @on_mention_selected)

  cleanup: ->
    @$container.empty()
    @mentions = []
    @mentions_data = {}

  on_focus: =>
    bud.pub('highlighter.changed', [@])

  highlighter_changed: (e, highlighter) =>
    bud.unsub('mention.clicked', @on_mention_selected)
    if highlighter == @
      bud.sub('mention.clicked', @on_mention_selected)

  on_mention_selected: (e, mention_data) =>
    @disable_mentions()
    @mentions.push(mention_data['name'])
    @mentions_data[mention_data['id']] = mention_data['name']

    text            = @text()
    cursor_position = @cursor_position()

    text_until_cursor = text.substr(0, cursor_position)
    at_index          = text_until_cursor.lastIndexOf('@')
    text_until_at     = text_until_cursor.substr(0, at_index)
    text_after_cursor = text.substr(cursor_position)

    @$textarea.val("#{text_until_at}#{mention_data['name']}#{text_after_cursor}")
    @update()
    @$textarea.selectRange(text_until_at.length + mention_data['name'].length)

  enable_mentions: ->
    @mentions_enabled = true
    @$users_list.show()

  disable_mentions: =>
    @mentions_enabled = false
    @$users_list.empty()
    @$users_list.hide()

  on_keyup: (e) =>
    if e.which == 27
      @disable_mentions()
      return false
    else if e.which == 16
      @enable_mentions()

    @update()
    @update_autocomplete()
    true

  on_keydown: =>
    @update()
    true

  update_autocomplete: ->
    return unless @mentions_enabled
    autocomplete_text = @autocomplete_text()

    if _.isEmpty(autocomplete_text)
      @disable_mentions()
    else
      if autocomplete_text.length > 1 && autocomplete_text.length < 20
        q = autocomplete_text.replace(/@/g, '')
        bud.Ajax.get '/mentions', {q: q, profile_id: @profile_id}, {replace: @on_replace}

  on_replace: (response) =>
    @$users_list.html(response['html'])
    bud.replace_html(@$users_list, response['html'])

  update_dimentions: ->
    @$textarea.height(@$container.height())
    @$textarea.width(@$container.width())

  update: ->
    message = @$textarea.val().replace(/\n/g, '<br>')

    unless _.isEmpty(@mentions)
      mentions = new RegExp("(@?(#{@mentions.join('|')}))", 'gi')
      message = message.replace(mentions, '<b>$2</b>')

    message = message.replace(/<\/b>[\s,]+<b>/g, '</b> <b>')

    @$container.html(message)
    @$textarea.val(message.replace(/<br>/g, '\n').replace(/(<([^>]+)>)/ig, ""))

    @update_dimentions()


  #################
  # RRIVATE
  #################


  text: ->
    @$textarea.val()

  autocomplete_text: ->
    text_until_cursor = @text().substr(0, @cursor_position())
    at_index = text_until_cursor.lastIndexOf('@')
    if at_index != -1
      return text_until_cursor.substr(at_index)

  cursor_position: ->
    @$textarea.getCursorPosition()
