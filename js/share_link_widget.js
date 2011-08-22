(function() {
  
//import ../util/event_bus.js
//import ../util/state_machine.js
//import cookie_settings.js
//import clipboard.js
//import social_network_selector.js
//import text_counter.js 
//import share_animator.js
//import text_area_manager.js
;
  var Clipboard, CookieSettings, LinkShortener, ShareAnimator, ShareNotifications, ShareWidget;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  ShareWidget = (function() {
    function ShareWidget(context) {
      var me;
      this.auth_token = context.auth_token;
      this.bus = context.event_bus;
      this.container = context.container;
      this.button = this.container.find("button.button");
      this.close = this.container.find("a#closeWidget");
      this.autoshorten = this.container.find("#autoshorten");
      this.brandbar_toggle = this.container.find("#link_redirect_only");
      this.textarea = this.container.find("#shareLink");
      this.controls = this.container.find("#shareControls");
      this.networks = this.container.find("#networkSelector");
      this.dom_text_counter = this.container.find("#textCounter");
      this.notification_container = this.container.find("#shareNotifications");
      this.original_textarea_bg = this.textarea.css("background-image");
      this.state_machine = new StateMachine("closed", this.bus);
      this.animator = new ShareAnimator(this.container, this.controls);
      this.textarea_manager = new TextAreaManager(this.textarea, this.auth_token, this.bus);
      this.network_selector = new SocialNetworkSelector(this.networks, this.bus);
      this.text_counter = new TextCounter(this.textarea, this.dom_text_counter, this.network_selector, this.state_machine, this.bus);
      this.ajax_manager = new ShareFormAjax(this.auth_token, this.bus);
      this.notifications = new ShareNotifications(this.notification_container, this.bus);
      this.clipboard = new Clipboard("clipboardContainer", "clipboardButton", this.textarea_manager, this.bus);
      this.state_machine.set_trigger("open-share-widget", "opened");
      this.state_machine.set_trigger("close-share-widget", "closed");
      me = this;
      this.state_machine.set_enter_transition("opened", function() {
        return me.open_share_widget.apply(me, arguments);
      });
      this.state_machine.set_enter_transition("closed", function() {
        return me.close_share_widget.apply(me, arguments);
      });
      this.set_autoshorten();
      this.bind_event_handlers();
      this.settings = new CookieSettings(document, JSON, this.bus);
    }
    ShareWidget.prototype.open_share_widget = function(text) {
      var me;
      if (this.state_machine.get_state() === "opened") {
        this.set_text_if_present(text);
        return;
      }
      me = this;
      return this.animator.open(function() {
        me.textarea_manager.clear();
        me.textarea_manager.focus();
        me.textarea_manager.set_line_height("25px");
        return me.set_text_if_present(text);
      });
    };
    ShareWidget.prototype.set_text_if_present = function(text) {
      if (text != null) {
        return this.textarea_manager.set(text);
      }
    };
    ShareWidget.prototype.close_share_widget = function() {
      var me;
      me = this;
      this.textarea_manager.reset_line_height();
      return this.animator.close(function() {
        return me.textarea_manager.set();
      });
    };
    ShareWidget.prototype.bind_event_handlers = function() {
      var me;
      me = this;
      this.textarea.click(function(e) {
        if (me.state_machine.get_state() === "open") {
          return;
        }
        me.state_machine.transition_to("opened");
        return me.bus.fire_event("open-share-widget", []);
      });
      this.close.click(function(e) {
        e.preventDefault();
        return me.bus.fire_event("close-share-widget");
      });
      this.bind_button_events();
      this.autoshorten.change(function() {
        return me.set_autoshorten();
      });
      return this.brandbar_toggle.change(function() {
        return me.set_brandbar();
      });
    };
    ShareWidget.prototype.publish = function(e) {
      e.preventDefault();
      return this.ajax_manager.publish(this.textarea_manager.content(), this.network_selector.get_selected_networks());
    };
    ShareWidget.prototype.bind_button_events = function() {
      var me;
      me = this;
      this.button.click(function() {
        return me.publish.apply(me, arguments);
      });
      this.bus.bind_event("network-selected", function() {
        return me.enable_button();
      });
      this.bus.bind_event("no-networks-selected", function() {
        return me.disable_button();
      });
      this.bus.bind_event("msg-too-long", function() {
        return me.disable_button();
      });
      this.bus.bind_event("msg-length-ok", function() {
        return me.enable_button();
      });
      this.bus.bind_event("shortening-links", function() {
        return me.disable_button();
      });
      return this.bus.bind_event("done-shortening-links", function() {
        return me.enable_button();
      });
    };
    ShareWidget.prototype.set_autoshorten = function() {
      var event_name;
      event_name = this.autoshorten.attr("checked") ? "autoshorten-enabled" : "autoshorten-disabled";
      return this.bus.fire_event(event_name);
    };
    ShareWidget.prototype.set_brandbar = function() {
      var event_name;
      event_name = this.brandbar_toggle.attr("checked") ? "brandbar-enabled" : "brandbar-disabled";
      return this.bus.fire_event(event_name);
    };
    ShareWidget.prototype.enable_button = function() {
      this.button.animate({
        opacity: 1
      }, 200);
      return this.button.removeAttr("disabled");
    };
    ShareWidget.prototype.disable_button = function() {
      this.button.attr("disabled", "disabled");
      return this.button.animate({
        opacity: .20
      }, 200);
    };
    return ShareWidget;
  })();
  ShareNotifications = (function() {
    function ShareNotifications(container, event_bus) {
      this.container = container;
      this.event_bus = event_bus;
      this.open_event = "open-share-notification";
      this.close_event = "close-share-notification";
      this.animation_speed = 200;
      this.open_bottom_distance = this.container.css("bottom");
      this.close_bottom_distance = "-12px";
      this.text_container = this.container.find(".notification-text").first();
      this.bind_events();
    }
    ShareNotifications.prototype.show = function(msg, close_after_miliseconds, callback) {
      var bus, close_event;
      this.container.css({
        bottom: this.close_bottom_distance,
        opacity: 0,
        display: "block"
      });
      this.container.animate({
        bottom: this.open_bottom_distance,
        opacity: 1
      }, this.animation_speed);
      if (msg != null) {
        this.text_container.html(msg);
      }
      if (close_after_miliseconds) {
        bus = this.event_bus;
        close_event = this.close_event;
        return setTimeout(function() {
          bus.fire_event(close_event);
          if (callback != null) {
            return callback();
          }
        }, close_after_miliseconds);
      }
    };
    ShareNotifications.prototype.close = function() {
      var container;
      container = this.container;
      return container.animate({
        bottom: "-12px",
        opacity: 0
      }, this.animation_speed, function() {
        return container.css({
          display: "none"
        });
      });
    };
    ShareNotifications.prototype.bind_events = function() {
      var me;
      me = this;
      this.event_bus.bind_event(this.open_event, function() {
        return me.show.apply(me, arguments);
      });
      return this.event_bus.bind_event(this.close_event, function() {
        return me.close.apply(me, arguments);
      });
    };
    return ShareNotifications;
  })();
  ShareAnimator = (function() {
    function ShareAnimator(container, controls, jQuery) {
      this.container = container;
      this.controls = controls;
      this.jQuery = jQuery != null ? jQuery : $;
      this.animation_speed = 350;
      this.focus_animation_settings = {
        width: '600px',
        height: '170px',
        "padding-top": "0",
        "padding-left": "10px",
        "padding-right": "10px",
        "padding-bottom": "0"
      };
      this.blur_animation_settings = {
        width: this.container.width() + "px",
        height: this.container.height() + "px",
        padding: "0"
      };
    }
    ShareAnimator.prototype.is_ie = function() {
      return this.jQuery.browser.msie === true;
    };
    ShareAnimator.prototype.open = function(callback) {
      var controls, me;
      me = this;
      controls = me.controls;
      return this.container.animate(this.focus_animation_settings, this.animation_speed, this.jQuery.easing["easeInQuad"], function() {
        controls.css({
          left: "0"
        });
        controls.animate({
          opacity: 1
        }, 200);
        return callback();
      });
    };
    ShareAnimator.prototype.close = function(callback) {
      var me;
      me = this;
      return this.controls.animate({
        opacity: 0
      }, 100, this.jQuery.easing["easeOutQuad"], function() {
        if (me.is_ie()) {
          return me.ie_close_animation(callback);
        } else {
          return me.default_close_animation(callback);
        }
      });
    };
    ShareAnimator.prototype.ie_close_animation = function(callback) {
      this.container.css(this.blur_animation_settings);
      if (callback != null) {
        return callback();
      }
    };
    ShareAnimator.prototype.default_close_animation = function(callback) {
      return this.container.animate(this.blur_animation_settings, this.animation_speed, this.jQuery.easing["easeOutQuad"], callback());
    };
    return ShareAnimator;
  })();
  LinkShortener = (function() {
    function LinkShortener(jQuery, auth_token, create_link_path) {
      this.jQuery = jQuery;
      this.auth_token = auth_token;
      this.create_link_path = create_link_path != null ? create_link_path : "/links";
    }
    LinkShortener.prototype.shorten_link = function(url, callback) {
      return this.jQuery.post(this.create_link_path, this.create_post_data(url), function(response) {
        return callback(response);
      });
    };
    LinkShortener.prototype.get_redirect_only_form_value = function() {
      return !(jQuery("#link_redirect_only").attr("checked"));
    };
    LinkShortener.prototype.create_post_data = function(url) {
      var redirect, token;
      token = this.auth_token;
      redirect = this.get_redirect_only_form_value();
      return {
        authenticity_token: token,
        link: {
          original: url,
          redirect_only: redirect
        }
      };
    };
    return LinkShortener;
  })();
  
//import ../util/cookie_manager.js
;
  CookieSettings = (function() {
    function CookieSettings(document, parser, event_bus) {
      this.document = document;
      this.parser = parser;
      this.event_bus = event_bus;
      this.cookies = new CookieManager(this.document);
      this.settings = this.get_json_settings();
      this.cookie_name = "publish-settings";
      this.hours_to_keep_cookie = 5;
      this.fire_initialization_events();
      this.bind_change_listeners();
    }
    CookieSettings.prototype.get_json_settings = function() {
      var cookie;
      cookie = this.cookies.get_cookie("publish-settings");
      if (!(cookie != null)) {
        return {};
      }
      return this.parser.parse(cookie);
    };
    CookieSettings.prototype.has_network_settings = function() {
      return __indexOf.call(settings, "networks") >= 0;
    };
    CookieSettings.prototype.save_settings = function() {
      return this.cookies.set_cookie(this.cookie_name, this.parser.stringify(this.settings), this.hours_to_keep_cookie);
    };
    CookieSettings.prototype.change_settings = function(key, value) {
      this.settings[key] = value;
      return this.save_settings();
    };
    CookieSettings.prototype.fire_initialization_events = function() {
      if (this.settings["networks"] === "twitter" || !this.has_network_settings()) {
        return this.event_bus.fire_event("twitter_selected");
      } else {
        return this.event_bus.fire_event("twitter_deselected");
      }
    };
    CookieSettings.prototype.bind_change_listeners = function() {
      var me;
      me = this;
      this.event_bus.bind_event("twitter_selected", function() {
        return me.change_settings("networks", "twitter");
      });
      this.event_bus.bind_event("no-networks-selected", function() {
        return me.change_settings("networks", null);
      });
      this.event_bus.bind_event("brandbar-enabled", function() {
        return me.change_settings("brandbar", true);
      });
      this.event_bus.bind_event("brandbar-disabled", function() {
        return me.change_settings("brandbar", false);
      });
      this.event_bus.bind_event("autoshorten-disabled", function() {
        return me.change_settings("autoshorten", false);
      });
      return this.event_bus.bind_event("autoshorten-enabled", function() {
        return me.change_settings("autoshorten", true);
      });
    };
    return CookieSettings;
  })();
  Clipboard = (function() {
    function Clipboard(button_container_id, button_id, textarea_manager, event_bus) {
      var clip, notification_duration;
      ZeroClipboard.setMoviePath('/flash/ZeroClipboard.swf');
      notification_duration = 800;
      clip = new ZeroClipboard.Client();
      clip.setHandCursor(true);
      clip.addEventListener('mouseOver', function(client) {
        return clip.setText(textarea_manager.content());
      });
      clip.addEventListener('complete', function(client, text) {
        return event_bus.fire_event("open-share-notification", ["Copying to clipboard", notification_duration]);
      });
      clip.glue(button_id, button_container_id);
    }
    return Clipboard;
  })();
}).call(this);
