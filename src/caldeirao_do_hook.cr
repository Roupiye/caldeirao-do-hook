require "kemal"

class Hook
  getter :body, :last_accessed
  @body : String
  @last_accessed : Time | Nil

  def initialize(body)
    @body = body
    @last_accessed = nil
  end

  def access!
    @last_accessed = Time.local
  end
end

class HookStore
  @@hooks = [] of Hook

  def self.save(hook)
    @@hooks << hook
  end

  def self.get
    hooks = @@hooks.select{ |h| h.last_accessed.nil? }
    hooks.each { |h| h.access! }

    hooks.map { |h| h.body }
  end
end

def save_hook(env, from_query = false)
  if from_query
    hook = Hook.new(env.params.query.to_s)
    HookStore.save(hook)
  else
    hook = Hook.new(env.params.json.to_json)
    HookStore.save(hook)
  end
end

get("/*") { |env| save_hook(env, from_query: true); "data saved!" }
post("/*") { |env| save_hook(env); "data saved!" }
patch("/*") { |env| save_hook(env); "data saved!" }
delete("/*") { |env| save_hook(env); "data saved!" }

get "/" do |env|
  env.response.content_type = "application/json"
  HookStore.get.to_json
end

port = (ENV["PORT"]? || 3000).to_i
Kemal.run port
