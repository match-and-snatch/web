#= require ./form

class bud.widgets.UploadForm extends bud.widgets.Form
  @SELECTOR: '.UploadForm'
  @TRANSLOADIT_SCRIPT_PATH: '//assets.transloadit.com/js/jquery.transloadit2-latest.js?new_one=1'

  initialize: ->
    super
    @allowed_extensions = (@$container.find('input[type=file]').attr('accept') || '').toLowerCase().split(',')
    @$target = bud.get(@$container.data('target'))
    @upload_ticks_count = 0
    @processing_ticks_count = 0.0
    bud.sub('post', @on_post)
    bud.sub('attachment.cancel', @on_cancel)
    bud.Ajax.getScript(bud.widgets.UploadForm.TRANSLOADIT_SCRIPT_PATH).done(@on_script_loaded)

  destroy: ->
    bud.unsub('post', @on_post)
    bud.unsub('attachment.cancel', @on_cancel)

  on_script_loaded: =>
    @$container.attr('enctype', 'multipart/form-data')
    @$container.transloadit.i18n.en =
      'errors.BORED_INSTANCE_ERROR': 'Something went wrong. Please restart your upload process.'
      'errors.CONNECTION_ERROR': 'Sorry, your upload failed due to connection issues. Please restart your upload process.'
      'errors.MAX_SIZE_EXCEEDED': 'Your video file size is too large. Please keep files under 2GB.'
      'errors.unknown': 'There was an internal error. Please restart your upload process.'
      'errors.tryAgain': 'Please restart your upload process.'
      'errors.troubleshootDetails': 'If you would like our help to troubleshoot this, please email us this information:'
      cancel: 'Cancel'
      details: 'Details'
      startingUpload: 'Starting upload ...'
      processingFiles: 'Processing files'
      uploadProgress: '%s MB / %s MB (%s kB / sec)'
    @$container.transloadit(
      wait: true
      triggerUploadOnFileSelection: true
      fields: "input[name=slug]"
      modal: false
      onProgress: (bytesReceived, bytesExpected, assembly) =>
        @change_progress if bytesExpected == 0 then 0 else (bytesReceived / bytesExpected * 100).toFixed(2)
      onUpload: (upload, assembly) =>
        #@$target.prepend("<div>#{upload.name} is uploaded.</div>")
      onSuccess: (assembly) =>
        @finalize()
        setTimeout(=>
          $('.Progress').addClass('hidden')
          @change_progress 0
          bud.pub('attachment.uploaded')
          @$container.find('.select_file_container').removeClass('hidden')
        , 1000)
      onStart: (assembly) =>
        bud.pub('upload_form.set_uploading_state', [true])
        @$container.find('.select_file_container').addClass('hidden')
        $('.Progress').removeClass('hidden')
        bud.pub('attachment.uploading')
        if @has_invalid_file_extension
          bud.pub('attachment.cancel')
          @notify_file_invalid()
      onFileSelect: (fileName, $fileInputField) =>
        @validate_file_extension(fileName, $fileInputField)
      onError: (error) =>
        console.log(error) if console
        $('.Progress').addClass('hidden')
        @change_progress 0
        bud.pub('attachment.uploaded')

        if error.error == 'MAX_SIZE_EXCEEDED'
          @notify_file_invalid('Your video file size is too large. Please keep files under 2GB.')
        else
          @notify_file_invalid(error.message)
    )

  on_cancel: =>
    $('.Progress').addClass('hidden')
    @change_progress 0
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
    progress_bar = $("#progressbar")
    status_label = $("#uploading-status")
    percentage_label = $("#uploading-percentage")

    if progress < 100
      @upload_ticks_count += 1
      percentage_label.text("#{progress}%")
      progress_bar.width("#{progress}%")
      status_label.text('Uploading...')
      progress_bar.removeClass('progress-bar-success').addClass('progress-bar-info')
    else
      @processing_ticks_count += 0.5

      if @processing_ticks_count < @upload_ticks_count - 1
        progress = (@processing_ticks_count * 100 / @upload_ticks_count).toFixed(2)
        percentage_label.text("#{progress}%")
        progress_bar.width("#{progress}%")
        status_label.text('Processing...')
      else
        @finalize()

      progress_bar.removeClass('progress-bar-info').addClass('progress-bar-success')

  finalize: ->
    $("#uploading-percentage").text("Finalizing...")
    $("#progressbar").width("100%")
    $("#uploading-status").text('Processing...')

  reinit: () =>
    $(@$container).unbind('submit.transloadit');
    # transloadit not delete his fields. seems like it expects page to be reloaded
    @$container.find('textarea[name=transloadit]').remove()
    # it will realese transloadit callbacks. seems like it expects page to be reloaded
    bud.replace_container(@$container, @$container.removeClass('js-widget pending').clone())
    @on_script_loaded()

  validate_file_extension: (file_name, file_input) ->
    matched_ext = file_name.match(/\.[a-zA-Z0-9]+$/)
    file_extension = ''
    file_extension = matched_ext[0].toLowerCase() if matched_ext
    @has_invalid_file_extension = !(file_extension in @allowed_extensions) and !_.isEqual(@allowed_extensions, [''])

  notify_file_invalid: (message) ->
    @$container.find('.select_file_container').removeClass('hidden')
    alert(message || 'Sorry, but the file you are trying to upload is invalid')

