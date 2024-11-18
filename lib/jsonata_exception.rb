class JsonataException < StandardError
  def initialize(code, option)
    super(
      {
        code: code,
        **option,
        stack: Thread.current.backtrace
      }.to_json
    )
  end
end
