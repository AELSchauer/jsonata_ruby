class Functions
  def initialize(context:)
    @context = context
  end

  def lookup(input, key)
    result = nil
    if input.is_a?(Array)
      result = JSymbol::Sequence.new(context: @context)
      input.each do |input_step|
        res = lookup(input_step, key)
        if res.present?
          if Utils.is_sequence?(res)
            res.each { |val| result.push(val) }
          else
            result.push(res)
          end
        end
      end
    elsif input.is_a?(Hash) && !Utils.is_function?(input)
      result = input[key]
    end

    result
  end
end