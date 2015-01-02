#= require ./form

# Form used for posting user posts on profile page
class bud.widgets.Poster extends bud.widgets.Form
  @SELECTOR: '.Poster'

  initialize: ->
    bud.sub('attachment.uploading', @disable_submit)
    bud.sub('attachment.uploaded', @enable_submit)
    super

  destroy: ->
    bud.unsub('attachment.uploading', @disable_submit)
    bud.unsub('attachment.uploaded', @enable_submit)

  on_prepend: (response) =>
    super(response)
    @after_render()

  on_replace: (response) =>
    super(response)
    @after_render()

  after_render: ->
    @$container[0].reset()
    bud.pub('post')

  disable_submit: =>
    @$container.find('input[type=submit]').attr('disabled','disabled').val('Processing...');

  enable_submit: =>
    @$container.find('input[type=submit]').removeAttr('disabled').val('Post');