class JsonataException < StandardError
  def initialize(code, value)
    super(
      {
        code: code,
        value: value,
        stack: Thread.current.backtrace
      }.to_json
    )
  end
end
