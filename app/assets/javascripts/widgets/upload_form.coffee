#= require ./form

class bud.widgets.UploadForm extends bud.widgets.Form
  @SELECTOR: '.UploadForm'
  @TRANSLOADIT_SCRIPT_PATH: '//assets.transloadit.com/js/jquery.transloadit2-latest.js'

  initialize: ->
    super
    @$target = bud.get(@$container.data('target'))
    bud.sub('post', @on_post)
    bud.sub('attachment.cancel', @on_cancel)
    bud.Ajax.getScript(bud.widgets.UploadForm.TRANSLOADIT_SCRIPT_PATH).done(@on_script_loaded)

  on_script_loaded: =>
    @$container.attr('enctype', 'multipart/form-data')
    @$container.transloadit(
      wait: true
      triggerUploadOnFileSelection: true
      fields: "input[name=slug]"
      modal: false
      onProgress: (bytesReceived, bytesExpected, assembly) =>
        @change_progress (bytesReceived / bytesExpected * 100).toFixed(2) + '%'
      onUpload: (upload, assembly) =>
        #@$target.prepend("<div>#{upload.name} is uploaded.</div>")
      onSuccess: (assembly) =>
        $('#uploading > .file_status').addClass('hidden')
        @change_progress '0%'
        bud.pub('attachment.uploaded')
        @$container.find('.select_file_container').removeClass('hidden')
      onStart: (assembly) =>
        @$container.find('.select_file_container').addClass('hidden')
        $('#uploading > .file_status').removeClass('hidden')
        bud.pub('attachment.uploading')
      onError: (error) ->
        console.log(error) if console
        alert('Sorry, but file you are trying to upload is invalid')
    )

  on_cancel: =>
    $('#uploading > .file_status').addClass('hidden')
    @change_progress '0%'
    u = @$container.data('transloadit.uploader')
    if u && u.$files
      u.cancel()
  on_post: =>
    bud.clear_html(@$target)

  on_replace: (response) =>
    super
    @reinit()

  on_fail: (response) =>
    super
    @reinit()

  change_progress: (progress) ->
    $('.progress-bar-info').width(progress)
    $('.percentage').text(progress)

  reinit: () =>
    $(@$container).unbind('submit.transloadit');
    # transloadit not delete his fields. seems like it expects page to be reloaded
    @$container.find('textarea[name=transloadit]').remove()
    # it will realese transloadit callbacks. seems like it expects page to be reloaded
    bud.replace_container(@$container, @$container.removeClass('js-widget pending').clone())
    @on_script_loaded()
