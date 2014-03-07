(function() {
  (window.bud || (window.bud = {})).Core = (function() {
    function Core() {}

    Core.prototype.initialized = false;

    Core.instance = function() {
      return this.__instance || (this.__instance = new Core());
    };

    Core.initialize = function() {
      if (this.instance().initialized) {
        bud.Logger.error('Core already initialized');
        return;
      }
      return this.instance().__initialize();
    };

    Core.init_widgets = function(parent_container) {
      return _.each(window.bud.widgets, function(widget_class) {
        var error;
        try {
          return widget_class.init(parent_container);
        } catch (_error) {
          error = _error;
          return bud.Logger.error(error);
        }
      });
    };

    Core.prototype.__initialize = function() {
      bud.Core.init_widgets();
      return this.initialized = true;
    };

    return Core;

  })();

}).call(this);
(function() {
  (function() {
    var o;
    o = $(window.bud);
    window.bud.sub = function() {
      return o.on.apply(o, arguments);
    };
    window.bud.unsub = function() {
      return o.off.apply(o, arguments);
    };
    return window.bud.pub = function() {
      return o.trigger.apply(o, arguments);
    };
  })();

  window.bud.replace_container = function(container, replacement) {
    var $container, $parent;
    $container = $(container);
    $parent = $container.parent();
    $container.replaceWith(replacement);
    return bud.Core.init_widgets($parent);
  };

  window.bud.replace_html = function(container, replacement) {
    $(container).html(replacement);
    return bud.Core.init_widgets(container);
  };

  window.bud.append_html = function(container, replacement) {
    $(container).append(replacement);
    return bud.Core.init_widgets(container);
  };

  window.bud.prepend_html = function(container, replacement) {
    $(container).prepend(replacement);
    return bud.Core.init_widgets(container);
  };

  window.bud.clear_html = function(container) {
    return $(container).html('');
  };

}).call(this);
(function($, undefined) {

/**
 * Unobtrusive scripting adapter for jQuery
 * https://github.com/rails/jquery-ujs
 *
 * Requires jQuery 1.7.0 or later.
 *
 * Released under the MIT license
 *
 */

  // Cut down on the number of issues from people inadvertently including jquery_ujs twice
  // by detecting and raising an error when it happens.
  if ( $.rails !== undefined ) {
    $.error('jquery-ujs has already been loaded!');
  }

  // Shorthand to make it a little easier to call public rails functions from within rails.js
  var rails;
  var $document = $(document);

  $.rails = rails = {
    // Link elements bound by jquery-ujs
    linkClickSelector: 'a[data-confirm], a[data-method], a[data-remote], a[data-disable-with]',

    // Button elements bound by jquery-ujs
    buttonClickSelector: 'button[data-remote]',

    // Select elements bound by jquery-ujs
    inputChangeSelector: 'select[data-remote], input[data-remote], textarea[data-remote]',

    // Form elements bound by jquery-ujs
    formSubmitSelector: 'form',

    // Form input elements bound by jquery-ujs
    formInputClickSelector: 'form input[type=submit], form input[type=image], form button[type=submit], form button:not([type])',

    // Form input elements disabled during form submission
    disableSelector: 'input[data-disable-with], button[data-disable-with], textarea[data-disable-with]',

    // Form input elements re-enabled after form submission
    enableSelector: 'input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled',

    // Form required input elements
    requiredInputSelector: 'input[name][required]:not([disabled]),textarea[name][required]:not([disabled])',

    // Form file input elements
    fileInputSelector: 'input[type=file]',

    // Link onClick disable selector with possible reenable after remote submission
    linkDisableSelector: 'a[data-disable-with]',

    // Make sure that every Ajax request sends the CSRF token
    CSRFProtection: function(xhr) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) xhr.setRequestHeader('X-CSRF-Token', token);
    },

    // making sure that all forms have actual up-to-date token(cached forms contain old one)
    refreshCSRFTokens: function(){
      var csrfToken = $('meta[name=csrf-token]').attr('content');
      var csrfParam = $('meta[name=csrf-param]').attr('content');
      $('form input[name="' + csrfParam + '"]').val(csrfToken);
    },

    // Triggers an event on an element and returns false if the event result is false
    fire: function(obj, name, data) {
      var event = $.Event(name);
      obj.trigger(event, data);
      return event.result !== false;
    },

    // Default confirm dialog, may be overridden with custom confirm dialog in $.rails.confirm
    confirm: function(message) {
      return confirm(message);
    },

    // Default ajax function, may be overridden with custom function in $.rails.ajax
    ajax: function(options) {
      return $.ajax(options);
    },

    // Default way to get an element's href. May be overridden at $.rails.href.
    href: function(element) {
      return element.attr('href');
    },

    // Submits "remote" forms and links with ajax
    handleRemote: function(element) {
      var method, url, data, elCrossDomain, crossDomain, withCredentials, dataType, options;

      if (rails.fire(element, 'ajax:before')) {
        elCrossDomain = element.data('cross-domain');
        crossDomain = elCrossDomain === undefined ? null : elCrossDomain;
        withCredentials = element.data('with-credentials') || null;
        dataType = element.data('type') || ($.ajaxSettings && $.ajaxSettings.dataType);

        if (element.is('form')) {
          method = element.attr('method');
          url = element.attr('action');
          data = element.serializeArray();
          // memoized value from clicked submit button
          var button = element.data('ujs:submit-button');
          if (button) {
            data.push(button);
            element.data('ujs:submit-button', null);
          }
        } else if (element.is(rails.inputChangeSelector)) {
          method = element.data('method');
          url = element.data('url');
          data = element.serialize();
          if (element.data('params')) data = data + "&" + element.data('params');
        } else if (element.is(rails.buttonClickSelector)) {
          method = element.data('method') || 'get';
          url = element.data('url');
          data = element.serialize();
          if (element.data('params')) data = data + "&" + element.data('params');
        } else {
          method = element.data('method');
          url = rails.href(element);
          data = element.data('params') || null;
        }

        options = {
          type: method || 'GET', data: data, dataType: dataType,
          // stopping the "ajax:beforeSend" event will cancel the ajax request
          beforeSend: function(xhr, settings) {
            if (settings.dataType === undefined) {
              xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
            }
            return rails.fire(element, 'ajax:beforeSend', [xhr, settings]);
          },
          success: function(data, status, xhr) {
            element.trigger('ajax:success', [data, status, xhr]);
          },
          complete: function(xhr, status) {
            element.trigger('ajax:complete', [xhr, status]);
          },
          error: function(xhr, status, error) {
            element.trigger('ajax:error', [xhr, status, error]);
          },
          crossDomain: crossDomain
        };

        // There is no withCredentials for IE6-8 when
        // "Enable native XMLHTTP support" is disabled
        if (withCredentials) {
          options.xhrFields = {
            withCredentials: withCredentials
          };
        }

        // Only pass url to `ajax` options if not blank
        if (url) { options.url = url; }

        var jqxhr = rails.ajax(options);
        element.trigger('ajax:send', jqxhr);
        return jqxhr;
      } else {
        return false;
      }
    },

    // Handles "data-method" on links such as:
    // <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
    handleMethod: function(link) {
      var href = rails.href(link),
        method = link.data('method'),
        target = link.attr('target'),
        csrfToken = $('meta[name=csrf-token]').attr('content'),
        csrfParam = $('meta[name=csrf-param]').attr('content'),
        form = $('<form method="post" action="' + href + '"></form>'),
        metadataInput = '<input name="_method" value="' + method + '" type="hidden" />';

      if (csrfParam !== undefined && csrfToken !== undefined) {
        metadataInput += '<input name="' + csrfParam + '" value="' + csrfToken + '" type="hidden" />';
      }

      if (target) { form.attr('target', target); }

      form.hide().append(metadataInput).appendTo('body');
      form.submit();
    },

    /* Disables form elements:
      - Caches element value in 'ujs:enable-with' data store
      - Replaces element text with value of 'data-disable-with' attribute
      - Sets disabled property to true
    */
    disableFormElements: function(form) {
      form.find(rails.disableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        element.data('ujs:enable-with', element[method]());
        element[method](element.data('disable-with'));
        element.prop('disabled', true);
      });
    },

    /* Re-enables disabled form elements:
      - Replaces element text with cached value from 'ujs:enable-with' data store (created in `disableFormElements`)
      - Sets disabled property to false
    */
    enableFormElements: function(form) {
      form.find(rails.enableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        if (element.data('ujs:enable-with')) element[method](element.data('ujs:enable-with'));
        element.prop('disabled', false);
      });
    },

   /* For 'data-confirm' attribute:
      - Fires `confirm` event
      - Shows the confirmation dialog
      - Fires the `confirm:complete` event

      Returns `true` if no function stops the chain and user chose yes; `false` otherwise.
      Attaching a handler to the element's `confirm` event that returns a `falsy` value cancels the confirmation dialog.
      Attaching a handler to the element's `confirm:complete` event that returns a `falsy` value makes this function
      return false. The `confirm:complete` event is fired whether or not the user answered true or false to the dialog.
   */
    allowAction: function(element) {
      var message = element.data('confirm'),
          answer = false, callback;
      if (!message) { return true; }

      if (rails.fire(element, 'confirm')) {
        answer = rails.confirm(message);
        callback = rails.fire(element, 'confirm:complete', [answer]);
      }
      return answer && callback;
    },

    // Helper function which checks for blank inputs in a form that match the specified CSS selector
    blankInputs: function(form, specifiedSelector, nonBlank) {
      var inputs = $(), input, valueToCheck,
          selector = specifiedSelector || 'input,textarea',
          allInputs = form.find(selector);

      allInputs.each(function() {
        input = $(this);
        valueToCheck = input.is('input[type=checkbox],input[type=radio]') ? input.is(':checked') : input.val();
        // If nonBlank and valueToCheck are both truthy, or nonBlank and valueToCheck are both falsey
        if (!valueToCheck === !nonBlank) {

          // Don't count unchecked required radio if other radio with same name is checked
          if (input.is('input[type=radio]') && allInputs.filter('input[type=radio]:checked[name="' + input.attr('name') + '"]').length) {
            return true; // Skip to next input
          }

          inputs = inputs.add(input);
        }
      });
      return inputs.length ? inputs : false;
    },

    // Helper function which checks for non-blank inputs in a form that match the specified CSS selector
    nonBlankInputs: function(form, specifiedSelector) {
      return rails.blankInputs(form, specifiedSelector, true); // true specifies nonBlank
    },

    // Helper function, needed to provide consistent behavior in IE
    stopEverything: function(e) {
      $(e.target).trigger('ujs:everythingStopped');
      e.stopImmediatePropagation();
      return false;
    },

    //  replace element's html with the 'data-disable-with' after storing original html
    //  and prevent clicking on it
    disableElement: function(element) {
      element.data('ujs:enable-with', element.html()); // store enabled state
      element.html(element.data('disable-with')); // set to disabled state
      element.bind('click.railsDisable', function(e) { // prevent further clicking
        return rails.stopEverything(e);
      });
    },

    // restore element to its original state which was disabled by 'disableElement' above
    enableElement: function(element) {
      if (element.data('ujs:enable-with') !== undefined) {
        element.html(element.data('ujs:enable-with')); // set to old enabled state
        element.removeData('ujs:enable-with'); // clean up cache
      }
      element.unbind('click.railsDisable'); // enable element
    }

  };

  if (rails.fire($document, 'rails:attachBindings')) {

    $.ajaxPrefilter(function(options, originalOptions, xhr){ if ( !options.crossDomain ) { rails.CSRFProtection(xhr); }});

    $document.delegate(rails.linkDisableSelector, 'ajax:complete', function() {
        rails.enableElement($(this));
    });

    $document.delegate(rails.linkClickSelector, 'click.rails', function(e) {
      var link = $(this), method = link.data('method'), data = link.data('params'), metaClick = e.metaKey || e.ctrlKey;
      if (!rails.allowAction(link)) return rails.stopEverything(e);

      if (!metaClick && link.is(rails.linkDisableSelector)) rails.disableElement(link);

      if (link.data('remote') !== undefined) {
        if (metaClick && (!method || method === 'GET') && !data) { return true; }

        var handleRemote = rails.handleRemote(link);
        // response from rails.handleRemote() will either be false or a deferred object promise.
        if (handleRemote === false) {
          rails.enableElement(link);
        } else {
          handleRemote.error( function() { rails.enableElement(link); } );
        }
        return false;

      } else if (link.data('method')) {
        rails.handleMethod(link);
        return false;
      }
    });

    $document.delegate(rails.buttonClickSelector, 'click.rails', function(e) {
      var button = $(this);
      if (!rails.allowAction(button)) return rails.stopEverything(e);

      rails.handleRemote(button);
      return false;
    });

    $document.delegate(rails.inputChangeSelector, 'change.rails', function(e) {
      var link = $(this);
      if (!rails.allowAction(link)) return rails.stopEverything(e);

      rails.handleRemote(link);
      return false;
    });

    $document.delegate(rails.formSubmitSelector, 'submit.rails', function(e) {
      var form = $(this),
        remote = form.data('remote') !== undefined,
        blankRequiredInputs = rails.blankInputs(form, rails.requiredInputSelector),
        nonBlankFileInputs = rails.nonBlankInputs(form, rails.fileInputSelector);

      if (!rails.allowAction(form)) return rails.stopEverything(e);

      // skip other logic when required values are missing or file upload is present
      if (blankRequiredInputs && form.attr("novalidate") == undefined && rails.fire(form, 'ajax:aborted:required', [blankRequiredInputs])) {
        return rails.stopEverything(e);
      }

      if (remote) {
        if (nonBlankFileInputs) {
          // slight timeout so that the submit button gets properly serialized
          // (make it easy for event handler to serialize form without disabled values)
          setTimeout(function(){ rails.disableFormElements(form); }, 13);
          var aborted = rails.fire(form, 'ajax:aborted:file', [nonBlankFileInputs]);

          // re-enable form elements if event bindings return false (canceling normal form submission)
          if (!aborted) { setTimeout(function(){ rails.enableFormElements(form); }, 13); }

          return aborted;
        }

        rails.handleRemote(form);
        return false;

      } else {
        // slight timeout so that the submit button gets properly serialized
        setTimeout(function(){ rails.disableFormElements(form); }, 13);
      }
    });

    $document.delegate(rails.formInputClickSelector, 'click.rails', function(event) {
      var button = $(this);

      if (!rails.allowAction(button)) return rails.stopEverything(event);

      // register the pressed submit button
      var name = button.attr('name'),
        data = name ? {name:name, value:button.val()} : null;

      button.closest('form').data('ujs:submit-button', data);
    });

    $document.delegate(rails.formSubmitSelector, 'ajax:beforeSend.rails', function(event) {
      if (this == event.target) rails.disableFormElements($(this));
    });

    $document.delegate(rails.formSubmitSelector, 'ajax:complete.rails', function(event) {
      if (this == event.target) rails.enableFormElements($(this));
    });

    $(function(){
      rails.refreshCSRFTokens();
    });
  }

})( jQuery );
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  bud.Ajax = (function() {
    Ajax.get = function(path, params, callbacks) {
      if (callbacks == null) {
        callbacks = {};
      }
      return (new bud.Ajax(path, params, callbacks)).get();
    };

    Ajax.post = function(path, params, callbacks) {
      if (callbacks == null) {
        callbacks = {};
      }
      return (new bud.Ajax(path, params, callbacks)).post();
    };

    function Ajax(path, params, callbacks) {
      if (params == null) {
        params = {};
      }
      if (callbacks == null) {
        callbacks = {};
      }
      this.on_response_received = __bind(this.on_response_received, this);
      this.on_bad_response_received = __bind(this.on_bad_response_received, this);
      this.path = path;
      this.params = params;
      this.callbacks = callbacks;
      this.before = callbacks['before'] || function() {};
      this.after = callbacks['after'] || function() {};
    }

    Ajax.prototype.get = function() {
      return this.perform_request('GET');
    };

    Ajax.prototype.post = function() {
      return this.perform_request('POST');
    };

    Ajax.prototype.perform_request = function(type) {
      this.options = {};
      this.options['beforeSend'] = this.before;
      this.options['type'] = type;
      this.options['data'] = this.params;
      return $.ajax(this.path, this.options).done(this.on_response_received).fail(this.on_bad_response_received).always(this.after);
    };

    Ajax.prototype.on_bad_response_received = function() {
      return bud.Logger.error("Invalid request on " + this.path);
    };

    Ajax.prototype.on_response_received = function(response) {
      var callback;
      if (callback = this.callbacks[response['status']]) {
        return callback(response);
      } else {
        switch (response['status']) {
          case 'redirect':
            return window.location = response['url'] || window.location;
          case 'failed':
            return alert(response['message'] || ("Invalid request on " + this.path));
          case 'reload':
            return window.location.reload();
        }
      }
    };

    return Ajax;

  })();

}).call(this);
(function() {
  var _base;

  (_base = window.bud).config || (_base.config = {});

}).call(this);
(function() {
  bud.Logger = (function() {
    Logger.instance = function() {
      return this.__instance || (this.__instance = new bud.Logger(window.bud.config.log_level));
    };

    Logger.error = function(text) {
      return this.instance().error(text);
    };

    Logger.warning = function(text) {
      return this.instance().warning(text);
    };

    Logger.message = function(text) {
      return this.instance().message(text);
    };

    function Logger(log_level) {
      this.log_level = log_level || 0;
    }

    Logger.prototype.error = function(text) {
      if (this.log_level >= 1) {
        return console.error(text);
      }
    };

    Logger.prototype.warning = function(text) {
      if (this.log_level >= 2) {
        return console.warn(text);
      }
    };

    Logger.prototype.message = function(text) {
      if (this.log_level >= 3) {
        return console.log(text);
      }
    };

    return Logger;

  })();

}).call(this);
(function() {
  bud.widgets || (bud.widgets = {});

  bud.Widget = (function() {
    Widget.instances = [];

    Widget.SELECTOR = null;

    Widget.init = function(parent_container) {
      var widget_class;
      if (parent_container == null) {
        parent_container = $('body');
      }
      if (!this.SELECTOR) {
        return;
      }
      widget_class = this;
      return parent_container.find(widget_class.SELECTOR).not('.js-widget').each(function(index, container) {
        return new widget_class($(container));
      });
    };

    Widget.highlight_all = function() {
      return $('.js-widget').addClass('js-highlight');
    };

    Widget.dehighlight_all = function() {
      return $('.js-widget').removeClass('js-highlight');
    };

    function Widget(container) {
      if (container.hasClass('js-widget')) {
        bud.Logger.error("Widget: " + (this.class_name()) + " already initialized");
        return;
      }
      this.$container = container;
      this.initialize();
      this.$container.addClass('js-widget');
      bud.Logger.message("Widget: " + (this.class_name()) + " initialized");
      bud.Widget.instances.push(this);
    }

    Widget.prototype.class_name = function() {
      return this.__proto__.constructor.name;
    };

    Widget.prototype.initialize = function() {};

    return Widget;

  })();

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.AjaxContainer = (function(_super) {
    __extends(AjaxContainer, _super);

    function AjaxContainer() {
      this.render_page = __bind(this.render_page, this);
      this.link_clicked = __bind(this.link_clicked, this);
      return AjaxContainer.__super__.constructor.apply(this, arguments);
    }

    AjaxContainer.SELECTOR = '.AjaxContainer';

    AjaxContainer.prototype.initialize = function() {
      var request_path;
      request_path = this.$container.data('url');
      if (request_path) {
        this.render_path(request_path);
      }
      return this.$container.find('a').click(this.link_clicked);
    };

    AjaxContainer.prototype.link_clicked = function(e) {
      var link;
      link = $(e.currentTarget);
      this.render_path(link.attr('href'));
      return false;
    };

    AjaxContainer.prototype.render_path = function(request_path) {
      this.$container.addClass('pending');
      return bud.Ajax.get(request_path, {}, {
        success: this.render_page
      });
    };

    AjaxContainer.prototype.render_page = function(response) {
      bud.replace_html(this.$container, response['html']);
      return this.$container.removeClass('pending');
    };

    return AjaxContainer;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.AjaxFormLink = (function(_super) {
    __extends(AjaxFormLink, _super);

    function AjaxFormLink() {
      this.render_link = __bind(this.render_link, this);
      this.link_clicked = __bind(this.link_clicked, this);
      return AjaxFormLink.__super__.constructor.apply(this, arguments);
    }

    AjaxFormLink.SELECTOR = '.AjaxFormLink';

    AjaxFormLink.prototype.initialize = function() {
      this.url = this.$container.attr('href');
      this.data = this.$container.data();
      return this.$container.click(this.link_clicked);
    };

    AjaxFormLink.prototype.link_clicked = function() {
      this.$container.removeClass('active');
      this.$container.addClass('pending');
      bud.Ajax.post(this.url, this.data, {
        success: this.render_link
      });
      return false;
    };

    AjaxFormLink.prototype.render_link = function(response) {
      this.$container.removeClass('pending');
      this.$container.addClass('active');
      return bud.replace_html(this.$container, response['html']);
    };

    return AjaxFormLink;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.AjaxLink = (function(_super) {
    __extends(AjaxLink, _super);

    function AjaxLink() {
      this.render_page = __bind(this.render_page, this);
      this.link_clicked = __bind(this.link_clicked, this);
      return AjaxLink.__super__.constructor.apply(this, arguments);
    }

    AjaxLink.SELECTOR = '.AjaxLink';

    AjaxLink.prototype.initialize = function() {
      this.$target = $(this.$container.data('target'));
      return this.$container.click(this.link_clicked);
    };

    AjaxLink.prototype.link_clicked = function(e) {
      $(this.constructor.SELECTOR).removeClass('active pending');
      this.render_path(this.$container.attr('href'));
      this.$container.addClass('pending');
      return false;
    };

    AjaxLink.prototype.render_path = function(request_path) {
      this.$target.addClass('pending');
      return bud.Ajax.get(request_path, {}, {
        success: this.render_page
      });
    };

    AjaxLink.prototype.render_page = function(response) {
      this.$container.removeClass('pending');
      this.$container.addClass('active');
      bud.replace_html(this.$target, response['html']);
      this.$target.removeClass('pending');
      return this.$target.show();
    };

    return AjaxLink;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.Popup = (function(_super) {
    __extends(Popup, _super);

    function Popup() {
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      this.toggle = __bind(this.toggle, this);
      this.autoclose = __bind(this.autoclose, this);
      return Popup.__super__.constructor.apply(this, arguments);
    }

    Popup.SELECTOR = '.Popup';

    Popup.prototype.initialize = function() {
      this.identifier = this.$container.data('identifier');
      bud.sub("popup.show", this.autoclose);
      bud.sub("popup.toggle." + this.identifier, this.toggle);
      return this.$container.appendTo($('body'));
    };

    Popup.prototype.autoclose = function(e, widget) {
      if (widget !== this) {
        return this.hide();
      }
    };

    Popup.prototype.toggle = function() {
      if (this.$container.is(':visible')) {
        return this.hide();
      } else {
        return this.show();
      }
    };

    Popup.prototype.autoplace = function() {
      this.$container.css('margin-left', "-" + (this.width() / 2) + "px");
      return this.$container.css('margin-top', "-" + (this.height() / 2) + "px");
    };

    Popup.prototype.show = function() {
      bud.pub("popup.show", [this]);
      this.$container.show();
      this.autoplace();
      return bud.pub("popup.show.overlay");
    };

    Popup.prototype.hide = function() {
      this.$container.hide();
      return bud.pub("popup.hide");
    };

    Popup.prototype.width = function() {
      return this.$container.outerWidth();
    };

    Popup.prototype.height = function() {
      return this.$container.outerHeight();
    };

    return Popup;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.AjaxPopup = (function(_super) {
    __extends(AjaxPopup, _super);

    function AjaxPopup() {
      this.on_response_received = __bind(this.on_response_received, this);
      this.show = __bind(this.show, this);
      return AjaxPopup.__super__.constructor.apply(this, arguments);
    }

    AjaxPopup.SELECTOR = '.AjaxPopup';

    AjaxPopup.prototype.initialize = function() {
      AjaxPopup.__super__.initialize.apply(this, arguments);
      return this.url = this.$container.data('url');
    };

    AjaxPopup.prototype.show = function() {
      AjaxPopup.__super__.show.apply(this, arguments);
      return bud.Ajax.get(this.url, {}, {
        success: this.on_response_received
      });
    };

    AjaxPopup.prototype.on_response_received = function(response) {
      bud.replace_html(this.$container, response['html']);
      return this.autoplace();
    };

    return AjaxPopup;

  })(bud.widgets.Popup);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.Cleaner = (function(_super) {
    __extends(Cleaner, _super);

    function Cleaner() {
      this.on_click = __bind(this.on_click, this);
      return Cleaner.__super__.constructor.apply(this, arguments);
    }

    Cleaner.SELECTOR = '.Cleaner';

    Cleaner.prototype.initialize = function() {
      this.$target = $(this.$container.data('target'));
      return this.$container.click(this.on_click);
    };

    Cleaner.prototype.on_click = function() {
      return bud.clear_html(this.$target);
    };

    return Cleaner;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.Form = (function(_super) {
    __extends(Form, _super);

    function Form() {
      this.on_fail = __bind(this.on_fail, this);
      this.on_after = __bind(this.on_after, this);
      this.on_before = __bind(this.on_before, this);
      this.on_replace = __bind(this.on_replace, this);
      this.on_submit = __bind(this.on_submit, this);
      return Form.__super__.constructor.apply(this, arguments);
    }

    Form.SELECTOR = '.Form';

    Form.prototype.initialize = function() {
      this.$container.submit(this.on_submit);
      return this.$error = this.$container.find('.Error');
    };

    Form.prototype.on_submit = function() {
      bud.Ajax.post(this.$container.attr('action'), this.params(), {
        success: this.on_success,
        replace: this.on_replace,
        before: this.on_before,
        after: this.on_after,
        failed: this.on_fail
      });
      return false;
    };

    Form.prototype.on_success = function() {};

    Form.prototype.on_replace = function(response) {
      return bud.replace_container(this.$container, response['html']);
    };

    Form.prototype.on_before = function() {
      _.each(this.params(), (function(_this) {
        return function(value, field) {
          return _this.$container.find("[data-field]").html('').hide();
        };
      })(this));
      return this.$container.addClass('pending');
    };

    Form.prototype.on_after = function() {
      return this.$container.removeClass('pending');
    };

    Form.prototype.on_fail = function(response) {
      var errors, message;
      if (message = response['message']) {
        if (this.$error.length > 0) {
          this.$error.html(message);
        } else {
          alert(message);
        }
      }
      if (errors = response['errors']) {
        return _.each(errors, (function(_this) {
          return function(message, field) {
            return _this.$container.find("[data-field=" + field + "]").html(message).show();
          };
        })(this));
      }
    };

    Form.prototype.params = function() {
      var result;
      result = {};
      _.each(this.$container.find('input, select, textarea'), function(input) {
        var $input;
        $input = $(input);
        return result[$input.attr('name')] = $input.val();
      });
      return result;
    };

    return Form;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.Commenter = (function(_super) {
    __extends(Commenter, _super);

    function Commenter() {
      this.on_success = __bind(this.on_success, this);
      return Commenter.__super__.constructor.apply(this, arguments);
    }

    Commenter.SELECTOR = '.Commenter';

    Commenter.prototype.initialize = function() {
      Commenter.__super__.initialize.apply(this, arguments);
      this.$target = $(this.$container.data('target'));
      return this.$container.find('textarea').focus();
    };

    Commenter.prototype.on_success = function(response) {
      bud.append_html(this.$target, response['html']);
      return this.$container[0].reset();
    };

    return Commenter;

  })(bud.widgets.Form);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.HintPopup = (function(_super) {
    __extends(HintPopup, _super);

    function HintPopup() {
      return HintPopup.__super__.constructor.apply(this, arguments);
    }

    HintPopup.SELECTOR = '.HintPopup';

    return HintPopup;

  })(bud.widgets.Popup);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.MWidget = (function(_super) {
    __extends(MWidget, _super);

    function MWidget() {
      return MWidget.__super__.constructor.apply(this, arguments);
    }

    MWidget.SELECTOR = '.MWidget';

    MWidget.prototype.initialize = function() {
      return this.$container.html('I am here!!!');
    };

    return MWidget;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.Overlay = (function(_super) {
    __extends(Overlay, _super);

    function Overlay() {
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      return Overlay.__super__.constructor.apply(this, arguments);
    }

    Overlay.SELECTOR = '.Overlay';

    Overlay.instance = function() {
      var _base;
      return (_base = bud.widgets.Overlay).__instance != null ? _base.__instance : _base.__instance = new bud.widgets.Overlay($(this.SELECTOR));
    };

    Overlay.prototype.initialize = function() {
      if (!bud.widgets.Overlay.__instance) {
        bud.widgets.Overlay.__instance = this;
        bud.sub('popup.show.overlay', this.show);
        return bud.sub('popup.hide.overlay', this.hide);
      }
    };

    Overlay.prototype.show = function() {
      return this.$container.show();
    };

    Overlay.prototype.hide = function() {
      return this.$container.hide();
    };

    return Overlay;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.PopupTrigger = (function(_super) {
    __extends(PopupTrigger, _super);

    function PopupTrigger() {
      this.on_click = __bind(this.on_click, this);
      return PopupTrigger.__super__.constructor.apply(this, arguments);
    }

    PopupTrigger.SELECTOR = '.PopupTrigger';

    PopupTrigger.prototype.initialize = function() {
      this.identifier = this.$container.data('identifier');
      return this.$container.click(this.on_click);
    };

    PopupTrigger.prototype.on_click = function() {
      bud.pub("popup.toggle." + this.identifier);
      return false;
    };

    return PopupTrigger;

  })(bud.Widget);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  bud.widgets.Poster = (function(_super) {
    __extends(Poster, _super);

    function Poster() {
      this.on_success = __bind(this.on_success, this);
      return Poster.__super__.constructor.apply(this, arguments);
    }

    Poster.SELECTOR = '.Poster';

    Poster.prototype.initialize = function() {
      Poster.__super__.initialize.apply(this, arguments);
      return this.$target = $(this.$container.data('target'));
    };

    Poster.prototype.on_success = function(response) {
      bud.prepend_html(this.$target, response['html']);
      return this.$container[0].reset();
    };

    return Poster;

  })(bud.widgets.Form);

}).call(this);
(function() {
  $(document).ready(function() {
    return bud.Core.initialize();
  });

}).call(this);
