#= require ./form

# Uploads image via transloadit and replaces target with form action response (usually image itself)
# @data target [String] Target identifier
class bud.widgets.PictureUploadForm extends bud.widgets.Form
  @SELECTOR: '.PictureUploadForm'
  @TRANSLOADIT_SCRIPT_PATH: '//assets.transloadit.com/js/jquery.transloadit2-latest.js'

  initialize: ->
    super
    @$target = bud.get(@$container.data('target'))
    bud.Ajax.getScript(bud.widgets.PictureUploadForm.TRANSLOADIT_SCRIPT_PATH).done(@on_script_loaded)

  on_script_loaded: =>
    @$container.attr('enctype', 'multipart/form-data')
    @$container.transloadit({wait: true, triggerUploadOnFileSelection: true, fields: "input[name=slug]"})

  on_replace: (response) =>
    @$container.unbind('submit.transloadit');
    super
    @on_script_loaded()
    @$container.find('textarea[name=transloadit]').remove()

  destroy: ->
    @$container.unbind('submit.transloadit');
    @$container.find('textarea[name=transloadit]').remove()
    super
    @$container.unbind('submit.transloadit');
    @$container.find('textarea[name=transloadit]').remove()

