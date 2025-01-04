class Functions
  def initialize(context:)
    @context = context
  end

  # Append second argument to first
  # @param {Array|Object} arg1 - First argument
  # @param {Array|Object} arg2 - Second argument
  # @returns {*} Appended arguments
  def append(arg1, arg2)
    return arg2 if arg1.nil?
    return arg1 if arg2.nil?

    arg1 = Utils.create_sequence(arg1) unless arg1.is_a?(Array)
    arg2 = [arg2] unless arg2.is_a?(Array)

    arg1.concat(arg2)
  end

  # Evaluate an input and return a boolean
  # @param {*} arg - Arguments
  # @returns {boolean} Boolean
  def boolean(arg)
    Utils.is_numeric?(arg) ? !arg.zero? : arg.present?
  end

  # Rounds a number up to integer
  # @param {Number} arg - Argument
  # @returns {Number} rounded integer
  def ceil(arg)
    arg[0].nil? ? nil : arg[0].ceil
  end

  def lookup(input, key)
    if input.is_a?(Array)
      result = Utils.create_sequence()
      input.each do |input_step|
        res = lookup(input_step, key)
        if res.present?
          if res.is_a?(Array)
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

  # Sum function
  # @param {Object} arr - array of numbers
  # @returns {number} Total value of arguments
  def sum(args)
    args = args[0]
    if args.is_a?(Numeric)
      args
    elsif args.all? { |e| e.is_a?(Numeric) }
      args.sum
    else
      nil
    end
  end
end