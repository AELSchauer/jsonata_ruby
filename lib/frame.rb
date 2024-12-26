class Frame
  attr_accessor :is_parallel_call
  attr_writer :bindings

  def initialize(enclosing_environment = nil, bindings = {})
    @enclosing_environment = enclosing_environment
    @bindings = bindings.deep_stringify_keys
    @initialized_at = Time.now.utc
    @is_parallel_call = false
  end

  def bind(name, value)
    return nil if name == ""
    @bindings[name] = value
  end

  def lookup(name)
    @bindings[name] || @enclosing_environment.lookup(name)
  end

  def timestamp
    @enclosing_environment&.timestamp || nil
  end

  def global
    @enclosing_environment&.global || {"ancestry" => [nil]}
  end

  def now
    @initialized_at.to_datetime.iso8601
  end

  def millis
    (@initialized_at.to_f * 1000.0).to_i
  end
end
