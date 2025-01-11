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

  # Average function
  # @param {Object} args - Arguments
  # @returns {number} Average element in the array
  def average(args)
    args = args[0]
    if args.is_a?(Array) && args.count > 0
      (args.sum / args.count).round(10)
    elsif args.present?
      args
    else
      nil
    end
  end

  # Evaluate an input and return a boolean
  # @param {*} arg - Arguments
  # @returns {boolean} Boolean
  def boolean(arg)
    Utils.is_numeric?(arg) ? !arg.zero? : arg.present?
  end

  # Rounds a number up
  # @param {Number} arg - Argument
  # @returns {Number} rounded number
  def ceil(arg)
    arg[0].nil? ? nil : arg[0].ceil
  end

  # Count function
  # @param {Object} args - Arguments
  # @returns {number} Number of elements in the array
  def count(args)
    args = args[0]
    if args.is_a?(Array)
      args.count
    elsif args.present?
      1
    else
      0
    end
  end

  # Rounds a number down
  # @param {Number} arg - Argument
  # @returns {Number} rounded number
  def floor(arg)
    arg[0].nil? ? nil : arg[0].floor
  end

  # Join an array of strings
  # @param {Array} strs - array of string
  # @param {String} [separator] - the token that splits the string
  # @returns {String} The concatenated string
  def join(args)
    strs = args[0].is_a?(Array) ? args[0] : [args[0]]
    separator = args[1] || ""
    strs.nil? ? nil : strs.join(separator)
  end

  # Return value from an object for a given key
  # @param {Object} input - Object/Array
  # @param {String} key - Key in object
  # @returns {*} Value of key in object
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

  # Implements the merge sort (stable) with optional comparator function
  # @param {Array} arr - the array to sort
  # @param {*} comparator - comparator function
  # @returns {Array} - sorted array
  def sort(arr, comparator = nil)
    arr = arr[0]
    if arr.is_a?(Array)
      if comparator.present?
        raise "sort with custom comparison function"
      else
        arr.sort
      end
    elsif arr.present?
      [arr]
    else
      nil
    end
  end

  # Stringify arguments
  # @param {Object} arg - Arguments
  # @param {boolean} [prettify] - Pretty print the result
  # @returns {String} String from arguments
  def string(arg, prettify = false)
    raise "pretty string" if prettify

    return nil if arg.nil?
    return arg if arg.is_a?(String)

    # functions (built-in and lambda convert to empty string
    return "" if Utils.is_function?(arg)
    
    raise "D3001" if arg.is_a?(Numeric) && !arg.finite?

    arg = arg[0] if arg.is_a?(Array) && Utils.get(arg, :outer_wrapper)
    jsonify = Proc.new do |val| 
      if Utils.is_numeric?(val)
        val.round(10)
      elsif Utils.is_function?(val)
        ""
      else
        val
      end
    end
    if arg.is_a?(Array)
      arg.map(&jsonify)
    elsif arg.is_a?(Hash)
      arg.transform_values!(&jsonify)
    end

    prettify ? JSON.pretty_generate(arg) : arg.to_json
  end

  # Sum function
  # @param {Object} arr - array of numbers
  # @returns {number} Total value of arguments
  def sum(args)
    args = args[0]
    if args.is_a?(Array)
      args.sum.round(10)
    elsif args.present?
      args
    else
      nil
    end
  end
end