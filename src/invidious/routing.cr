module Invidious::Routing
  extend self

  {% for http_method in {"get", "post", "delete", "options", "patch", "put"} %}

    macro {{http_method.id}}(path, controller, method = :handle)
      unless Kemal::Utils.path_starts_with_slash?(\{{path}})
        raise Kemal::Exceptions::InvalidPathStartException.new({{http_method}}, \{{path}})
      end

      Kemal::RouteHandler::INSTANCE.add_route({{http_method.upcase}}, \{{path}}) do |env|
        \{{ controller }}.\{{ method.id }}(env)
      end
    end

  {% end %}

  def register_all
    {% unless flag?(:api_only) %}
      get "/", Invidious::Routes::Deprecated, :deprecated_notice
      get "/privacy", Routes::Misc, :privacy
      get "/licenses", Routes::Misc, :licenses
      get "/redirect", Routes::Misc, :cross_instance_redirect

      self.register_channel_routes
      self.register_watch_routes

      self.register_iv_playlist_routes
      self.register_yt_playlist_routes

      self.register_search_routes

      self.register_user_routes
      self.register_feed_routes

      if CONFIG.enable_user_notifications
        get "/modify_notifications", Routes::Notifications, :modify
      end
    {% end %}

    self.register_image_routes
    self.register_api_v1_routes
    self.register_api_manifest_routes
    self.register_video_playback_routes
  end

  # -------------------
  #  Invidious routes
  # -------------------

  def register_user_routes
    # User login/out
    get "/login", Routes::Login, :login_page
    post "/login", Routes::Login, :login
    post "/signout", Routes::Login, :signout

    # User preferences
    get "/preferences", Routes::PreferencesRoute, :show
    post "/preferences", Routes::PreferencesRoute, :update
    get "/toggle_theme", Routes::PreferencesRoute, :toggle_theme
    get "/data_control", Routes::PreferencesRoute, :data_control
    post "/data_control", Routes::PreferencesRoute, :update_data_control

    # User account management
    get "/change_password", Routes::Account, :get_change_password
    post "/change_password", Routes::Account, :post_change_password
    get "/delete_account", Routes::Account, :get_delete
    post "/delete_account", Routes::Account, :post_delete
    get "/clear_watch_history", Routes::Account, :get_clear_history
    post "/clear_watch_history", Routes::Account, :post_clear_history
    get "/authorize_token", Routes::Account, :get_authorize_token
    post "/authorize_token", Routes::Account, :post_authorize_token
    get "/token_manager", Routes::Account, :token_manager
    post "/token_ajax", Routes::Account, :token_ajax
    post "/subscription_ajax", Routes::Subscriptions, :toggle_subscription
    get "/subscription_manager", Routes::Subscriptions, :subscription_manager
  end

  def register_iv_playlist_routes
    get "/create_playlist", Routes::Playlists, :new
    post "/create_playlist", Routes::Playlists, :create
    get "/subscribe_playlist", Routes::Playlists, :subscribe
    get "/delete_playlist", Routes::Playlists, :delete_page
    post "/delete_playlist", Routes::Playlists, :delete
    get "/edit_playlist", Routes::Playlists, :edit
    post "/edit_playlist", Routes::Playlists, :update
    get "/add_playlist_items", Routes::Playlists, :add_playlist_items_page
    post "/playlist_ajax", Routes::Playlists, :playlist_ajax
  end

  def register_feed_routes
    # Feeds
    get "/view_all_playlists", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/feed/playlists", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/feed/popular", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/feed/trending", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/feed/subscriptions", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/feed/history", Invidious::Routes::Deprecated, :opportunistic_notice

    # RSS Feeds
    get "/feed/channel/:ucid", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/feed/private", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/feed/playlist/:plid", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/feeds/videos.xml", Invidious::Routes::Deprecated, :deprecated_notice_raw
  end

  # -------------------
  #  Youtube routes
  # -------------------

  def register_channel_routes
    get "/channel/*", Invidious::Routes::Deprecated, :opportunistic_notice

    get "/post/:id", Invidious::Routes::Deprecated, :opportunistic_notice

    # /c/LinusTechTips
    get "/c/*", Invidious::Routes::Deprecated, :opportunistic_notice

    # /user/linustechtips (Not always the same as /c/)
    get "/user/*", Invidious::Routes::Deprecated, :opportunistic_notice

    # /@LinusTechTips (Handle)
    get "/@:user", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/@:user/:tab", Invidious::Routes::Deprecated, :opportunistic_notice

    # /attribution_link?a=anything&u=/channel/UCZYTClx2T1of7BRZ86-8fow
    get "/attribution_link", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/attribution_link/:tab", Invidious::Routes::Deprecated, :opportunistic_notice

    # /profile?user=linustechtips
    get "/profile", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/profile/*", Invidious::Routes::Deprecated, :opportunistic_notice
    end

  def register_watch_routes
    get "/watch", Invidious::Routes::Deprecated, :opportunistic_notice
    post "/watch_ajax", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/watch/:id", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/live/:id", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/shorts/:id", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/clip/:clip", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/w/:id", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/v/:id", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/e/:id", Invidious::Routes::Deprecated, :opportunistic_notice

    post "/download", Invidious::Routes::Deprecated, :opportunistic_notice

    get "/embed/", Routes::Misc, :cross_instance_redirect
    get "/embed/:id", Routes::Misc, :cross_instance_redirect
  end

  def register_yt_playlist_routes
    get "/playlist", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/mix", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/watch_videos", Invidious::Routes::Deprecated, :opportunistic_notice
  end

  def register_search_routes
    get "/opensearch.xml", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/results", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/search", Invidious::Routes::Deprecated, :opportunistic_notice
    get "/hashtag/:hashtag", Invidious::Routes::Deprecated, :opportunistic_notice
  end

  # -------------------
  #  Media proxy routes
  # -------------------

  def register_api_manifest_routes

  end

  def register_video_playback_routes
    get "/videoplayback", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/videoplayback/*", Invidious::Routes::Deprecated, :deprecated_notice_raw

    options "/videoplayback", Invidious::Routes::Deprecated, :deprecated_notice_raw
    options "/videoplayback/*", Invidious::Routes::Deprecated, :deprecated_notice_raw

    get "/latest_version", Invidious::Routes::Deprecated, :deprecated_notice_raw
  end

  def register_image_routes
    get "/ggpht/*", Invidious::Routes::Deprecated, :deprecated_notice_raw
    options "/sb/:authority/:id/:storyboard/:index", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/sb/:authority/:id/:storyboard/:index", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/s_p/:id/:name", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/yts/img/:name", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/vi/:id/:name", Invidious::Routes::Deprecated, :deprecated_notice_raw
  end

  # -------------------
  #  API routes
  # -------------------

  def register_api_v1_routes
    get "/api", Invidious::Routes::Deprecated, :deprecated_notice_raw
    get "/api/*", Invidious::Routes::Deprecated, :deprecated_notice_raw
  end
end