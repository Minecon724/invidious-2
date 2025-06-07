{% skip_file if flag?(:api_only) %}

module Invidious::Routes::Deprecated
  def self.opportunistic_notice(env)
    if env.get? "user"
      return self.deprecated_notice(env)
    end

    return Invidious::Routes::Misc.cross_instance_redirect(env)
  end
  

  def self.deprecated_notice(env)
    locale = env.get("preferences").as(Preferences).locale
    templated "deprecated"
  end

  def self.deprecated_notice_raw(env)
    return "This Invidious instance cannot be used at this time. For more information, visit https://id.420129.xyz"
  end
end