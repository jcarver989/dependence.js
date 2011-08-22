`
//import ../util/event_bus.js
//import ../util/state_machine.js
//import cookie_settings.js
//import clipboard.js
//import social_network_selector.js
//import text_counter.js 
//import share_animator.js
//import text_area_manager.js
`

# Composite that glues the share widget together
class ShareWidget
  constructor: (context) ->
    @auth_token       = context.auth_token
    @bus              = context.event_bus
    @container        = context.container
    @button           = @container.find("button.button")
    @close            = @container.find("a#closeWidget")
    @autoshorten      = @container.find("#autoshorten")
    @brandbar_toggle  = @container.find("#link_redirect_only")
    @textarea         = @container.find("#shareLink")
    @controls         = @container.find("#shareControls")
    @networks         = @container.find("#networkSelector")
    @dom_text_counter = @container.find("#textCounter")
    @notification_container = @container.find("#shareNotifications")
    @original_textarea_bg = @textarea.css("background-image")

    @state_machine    = new StateMachine("closed", @bus)
    @animator         = new ShareAnimator(@container, @controls)
    @textarea_manager = new TextAreaManager(@textarea, @auth_token, @bus)
    @network_selector = new SocialNetworkSelector(@networks, @bus)
    @text_counter     = new TextCounter(@textarea, @dom_text_counter, @network_selector, @state_machine, @bus)
    @ajax_manager     = new ShareFormAjax(@auth_token, @bus)
    @notifications    = new ShareNotifications(@notification_container, @bus) 
    @clipboard        = new Clipboard("clipboardContainer", "clipboardButton", @textarea_manager, @bus)

    # states
    @state_machine.set_trigger("open-share-widget", "opened")
    @state_machine.set_trigger("close-share-widget", "closed")

    me = this
    @state_machine.set_enter_transition("opened", -> me.open_share_widget.apply(me, arguments))
    @state_machine.set_enter_transition("closed", -> me.close_share_widget.apply(me, arguments)) 
    @set_autoshorten()
    @bind_event_handlers()

    # instantiate this last since the cstr fires events - we want ensure the appropriate handlers are already bound 
    @settings = new CookieSettings(document, JSON, @bus)

  open_share_widget: (text) -> 

    if @state_machine.get_state() == "opened"
      @set_text_if_present(text)
      return

    me = this
    @animator.open(->
      me.textarea_manager.clear()
      me.textarea_manager.focus()
      me.textarea_manager.set_line_height("25px")
      me.set_text_if_present(text)
    )

  set_text_if_present: (text) -> @textarea_manager.set(text) if text?

  close_share_widget: ->
    me = this
    @textarea_manager.reset_line_height()
    @animator.close( -> me.textarea_manager.set())

  bind_event_handlers: ->
    me = this
    @textarea.click((e) ->
      return unless me.state_machine.get_state() != "open"
      me.state_machine.transition_to("opened")
      me.bus.fire_event("open-share-widget", [])
    )

    @close.click((e) -> 
      e.preventDefault()
      me.bus.fire_event("close-share-widget")
    )

    @bind_button_events()
    @autoshorten.change(-> me.set_autoshorten())
    @brandbar_toggle.change(-> me.set_brandbar())

  publish: (e) -> 
    e.preventDefault()
    @ajax_manager.publish(@textarea_manager.content(), @network_selector.get_selected_networks())

  bind_button_events: -> 
    me = this
    @button.click(-> me.publish.apply(me, arguments))
    @bus.bind_event("network-selected",      -> me.enable_button()) 
    @bus.bind_event("no-networks-selected",  -> me.disable_button())
    @bus.bind_event("msg-too-long",          -> me.disable_button())
    @bus.bind_event("msg-length-ok",         -> me.enable_button())
    @bus.bind_event("shortening-links",      -> me.disable_button())
    @bus.bind_event("done-shortening-links", -> me.enable_button())

  set_autoshorten: ->
    event_name = if @autoshorten.attr("checked") then "autoshorten-enabled" else "autoshorten-disabled"
    @bus.fire_event(event_name)

  set_brandbar: -> 
    event_name = if @brandbar_toggle.attr("checked") then "brandbar-enabled" else "brandbar-disabled"
    @bus.fire_event(event_name)

  enable_button: ->
    @button.animate({ opacity: 1 }, 200)
    @button.removeAttr("disabled")

  disable_button: ->
    @button.attr("disabled", "disabled")
    @button.animate({ opacity: .20 }, 200)
class ShareNotifications
  constructor: (@container, @event_bus) ->
    @open_event  = "open-share-notification"
    @close_event = "close-share-notification"
    @animation_speed = 200
    @open_bottom_distance  = @container.css("bottom")
    @close_bottom_distance = "-12px" 
    @text_container = @container.find(".notification-text").first()
    @bind_events()

  show: (msg, close_after_miliseconds, callback) ->
    @container.css({bottom : @close_bottom_distance, opacity: 0, display : "block" })
    @container.animate({ bottom : @open_bottom_distance, opacity: 1 }, @animation_speed)

    @text_container.html(msg) if msg?

    if close_after_miliseconds
      bus = @event_bus
      close_event = @close_event
      setTimeout(->
        bus.fire_event(close_event)
        callback() if callback?
      , close_after_miliseconds)

  close: ->
    container = @container
    container.animate({ bottom : "-12px", opacity: 0 }, @animation_speed, ->
      container.css({ display: "none" })
    )
  
  bind_events: ->
    me = this
    @event_bus.bind_event(@open_event,  -> me.show.apply(me, arguments))
    @event_bus.bind_event(@close_event, -> me.close.apply(me, arguments))


# Animates the share container (opening + closing)
class ShareAnimator
  constructor: (@container, @controls, @jQuery = $) ->
    @animation_speed = 350

    @focus_animation_settings = {
      width: '600px',
      height: '170px',
      "padding-top"    : "0",
      "padding-left"   : "10px",
      "padding-right"  : "10px",
      "padding-bottom" : "0"
    }

    @blur_animation_settings = {
      width: @container.width() + "px",
      height: @container.height()  + "px",
      padding: "0"
    }

  is_ie: -> @jQuery.browser.msie == true
  
  open: (callback) ->
    me = this
    controls = me.controls

    @container.animate(
      @focus_animation_settings, 
      @animation_speed,  
      @jQuery.easing["easeInQuad"], 
      ->
        controls.css({ left: "0" })
        controls.animate({ opacity: 1}, 200)
        callback()
    )
  
  close: (callback) ->
    me = this
    @controls.animate({ opacity: 0 }, 100, @jQuery.easing["easeOutQuad"], ->
      if me.is_ie() then me.ie_close_animation(callback) else me.default_close_animation(callback)
    )
  
  # Don't animate the closing of the widget in ie as calling animate in ie throws an exception
  ie_close_animation: (callback) ->
    @container.css(@blur_animation_settings)
    callback() if callback?

  default_close_animation: (callback) ->
    @container.animate(
      @blur_animation_settings,
      @animation_speed,
      @jQuery.easing["easeOutQuad"],
      callback()
    )
class LinkShortener
  constructor: (@jQuery, @auth_token, @create_link_path = "/links") ->

  shorten_link: (url, callback) ->
    @jQuery.post(
      @create_link_path, 
      @create_post_data(url), 
      (response) -> callback(response)
    )

   # supposed to be inverted 0 means - redirect, 1 means brand bar on
   get_redirect_only_form_value: -> !(jQuery("#link_redirect_only").attr("checked"))

   create_post_data: (url) ->
     token = @auth_token
     redirect = @get_redirect_only_form_value()

     {
       authenticity_token : token,
       link : {
         original : url,
         redirect_only : redirect 
       }
    }
`
//import ../util/cookie_manager.js
` 

# Serializes publish widget settings (json) to a cookie
class CookieSettings
  constructor: (@document, @parser, @event_bus) ->
    @cookies = new CookieManager(@document)
    @settings = @get_json_settings()
    @cookie_name = "publish-settings"
    @hours_to_keep_cookie = 5 

    #sets up the widget
    @fire_initialization_events()
    @bind_change_listeners()

  get_json_settings: -> 
    cookie = @cookies.get_cookie("publish-settings")
    return {} if !cookie?
    @parser.parse(cookie)

  has_network_settings: -> return "networks" in settings

  save_settings:  -> 
    @cookies.set_cookie(@cookie_name, @parser.stringify(@settings), @hours_to_keep_cookie)

  change_settings: (key, value) -> 
    @settings[key] = value
    @save_settings()

  fire_initialization_events: ->
    if (@settings["networks"] == "twitter" || !@has_network_settings()) 
      @event_bus.fire_event("twitter_selected")
    else
      @event_bus.fire_event("twitter_deselected")

  bind_change_listeners: -> 
    me = this
    @event_bus.bind_event("twitter_selected",     -> me.change_settings("networks", "twitter")) 
    @event_bus.bind_event("no-networks-selected", -> me.change_settings("networks", null))
    @event_bus.bind_event("brandbar-enabled",     -> me.change_settings("brandbar", true))
    @event_bus.bind_event("brandbar-disabled",    -> me.change_settings("brandbar", false))
    @event_bus.bind_event("autoshorten-disabled", -> me.change_settings("autoshorten", false))
    @event_bus.bind_event("autoshorten-enabled",  -> me.change_settings("autoshorten", true))
class Clipboard
  constructor: (button_container_id, button_id, textarea_manager, event_bus) ->
    ZeroClipboard.setMoviePath('/flash/ZeroClipboard.swf')
    notification_duration = 800
    clip = new ZeroClipboard.Client()
    clip.setHandCursor(true)

    clip.addEventListener('mouseOver', (client) ->
      clip.setText(textarea_manager.content())
    )

    clip.addEventListener('complete', (client, text) ->
      event_bus.fire_event("open-share-notification", ["Copying to clipboard", notification_duration])
    )

    clip.glue(button_id, button_container_id)
