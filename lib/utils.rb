require "json"
require "./lib/jsonata_exception"

class Utils
  class << self
    # TO-DO Comments
    def create_sequence(*args)
      sequence = []
      Utils.set(sequence, :sequence, true)
      if args.length == 1
        sequence << args[0]
      end
      sequence
    end

    # TO-DO Comments
    def get(obj, key)
      obj.instance_variable_get("@#{key}")
    end

    # TO-DO Comments
    def set(obj, key, val)
      obj.instance_variable_set("@#{key}", val)
      obj
    end

    # Check if value is a finite number
    # @param {float} n - number to evaluate
    # @returns {boolean} True if n is a finite number
    def is_numeric?(n)
      is_num = false
      if n.is_a?(Numeric)
        is_num = !n.to_f.nan?
        if is_num && !n.finite?
          # raise JsonataException.new("D1001", {value: n.to_s})
          raise "D1001"
        end
      end
      is_num
    end

    # Returns true if the arg is an array of strings
    # @param {*} arg - the item to test
    # @returns {boolean} True if arg is an array of strings
    def is_array_of_strings(arg)
      return false unless arg.is_a?(Array)
      arg.all? { |item| item.is_a?(String) }
    end

    # Returns true if the arg is an array of numbers
    # @param {*} arg - the item to test
    # @returns {boolean} True if arg is an array of numbers
    def is_array_of_numbers?(arg)
      return false unless arg.is_a?(Array)
      arg.all? { |item| is_numeric?(item) }
    end

    
    # Compares two values for equality
    # @param {*} lhs first value
    # @param {*} rhs second value
    # @returns {boolean} true if they are deep equal
    def is_deep_equal(lhs, rhs)
      return true if lhs == rhs

      if lhs.is_a?(Array) && rhs.is_a?(Array)
        if lhs.length != rhs.length
          false
        else
          lhs.length.times.all? { |i| is_deep_equal(lhs[i], rhs[i]) }
        end
      elsif lhs.is_a?(Hash) && rhs.is_a?(Hash)
        lhs.transform_keys!(&:to_s)
        rhs.transform_keys!(&:to_s)
        lkeys = lhs.keys
        rkeys = rhs.keys

        if lkeys.length != rkeys.length
          false
        elsif (lkeys - rkeys | rkeys - lkeys).any?
          false
        else
          lkeys.all? { |key| is_deep_equal(lhs[key], rhs[key]) }
        end
      else
        false
      end
    end

    # @param {Object} arg - expression to test
    # @returns {boolean} - true if it is a function (lambda or built-in)
    def is_function?(arg)
      false
    end

    def is_lambda?(arg)
      false
    end

    def is_iterable?(arg)
      false
    end

    # converts a string to an array of characters
    # @param {string} str - the input string
    # @returns {Array} - the array of characters
    def string_to_array(str)
      return [] unless str.is_a?(String)
      str.split("")
    end
  end
end
