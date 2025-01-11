class Signature
  def initialize(signature)
    @position = 1
    @params = []
    @param = {}
    @prev_param = {}
    @signature = signature
    parse
  end

  def parse(position = 1)
    return nil if @signature.nil?

    while @position < @signature.length
      symbol = @signature[@position]
      if symbol == ":"
        # TODO figure out what to do with the return type
        # ignore it for now
        break;
      end

      case symbol
      when "s", "n", "b", "o", "l" # string, number, boolean, object, not so sure about expecting null?
        @param["regex"] = "[#{symbol}m]"
        @param["type"] = symbol
        next_symbol
      when "a" # array
        @param["regex"] = "[asnblfom]";
        @param["type"] = symbol;
        @param["array"] = true;
        next_symbol
      when "f" # function
        @param["regex"] = "f"
        @param["type"] = symbol
        next_symbol
      when "j" # any JSON type
        @param["regex"] = "[asnblom]";
        @param["type"] = symbol;
        next_symbol
      when "x" # any type
        @param["regex"] = "[asnblfom]";
        @param["type"] = symbol;
        next_symbol
      when "-" # use context if param not supplied
        @prev_param["context"] = true;
        @prev_param["context_regex"] = Regexp.new(@prev_param["regex"]) # pre-compiled to test the context type at runtime
        @prev_param["regex"] += '?';
      when "?", "+" # optional param, one or more
        @prev_param["regex"] += symbol;
      when "(" # choice of types
        # search forward for matching ')'
        end_pos = find_closing_bracket(@signature, position, "(", ")")
        choice = @signature[@position + 1, end_pos - (@position + 1)]
        if choice.index("<").nil?
          @param["regex"] = "[#{choice}m]"
        else
          # TODO harder
          raise "S0402"
        end
        @param["type"] = "(#{choice})"
        position = end_pos
        next_symbol
      when "<" # type parameter - can only be applied to 'a' and 'f'
        if @prev_param["type"] === "a" || @prev_param["type"] === "f"
          end_pos = find_closing_bracket(@signature, @position, "<", ">")
          @prev_param["subtype"] = @signature[@position + 1, end_pos - (@position + 1)]
          @position = end_pos
        else
          raise "S0401"
        end
      end

      @position += 1
    end
    @regex = Regexp.new("^" + @params.map { |prm| "(" + prm["regex"] + ")" }.join("") + "$")
  end

  def find_closing_bracket(str, start, open_sym, close_sym)
    # returns the position of the closing symbol (e.g. bracket) in a string
    # that balances the opening symbol at position start
    depth = 1
    position = start
    while position < str.length
      position += 1
      sym = str[position]
      if sym == close_sym
        depth -= 1
        break if depth == 0
      elsif sym == open_sym
        depth += 1
      end
    end
    position
  end

  def next_symbol()
    @params.push(@param)
    @prev_param = @param
    @param = {}
  end

  def get_symbol(val)
    if val.nil?
      "m"
    elsif Utils.is_function?(val)
      "f"
    elsif val.is_a?(String)
      "s"
    elsif val.is_a?(Numeric)
      "n"
    elsif val.is_a?(TrueClass) || val.is_a?(FalseClass)
      "b"
    elsif val.is_a?(Array)
      "a"
    elsif val.is_a?(Hash)
      "o"
    else # m for missing
      "m"
    end
  end

  # Validate the arguments against the signature validator (if it exists)
  # @param {Function} signature - validator function
  # @param {Array} args - function arguments
  # @param {*} context - context value
  # @returns {Array} - validated arguments
  def validate_arguments(args, context)
    return args if @signature.nil?

    supplied_sig = args.map { |arg| get_symbol(arg) }.join("")
    if @regex.match?(supplied_sig)
      validated_args = []
      arg_index = 0
      @params.each.with_index do |param, index|
        arg = args[arg_index]
        match = @regex.match(supplied_sig)[1]
        if match == ""
          raise "validate_arguments ''"
        else
          # may have matched multiple args (if the regex ends with a '+'
          # split into single tokens
          match.split("").each do |single|
            if @param["type"] == "a"
              if single == "m"
                # missing (undefined)
                arg = nil
              else
                arg = args[arg_index]
                array_ok = true
                # is there type information on the contents of the array?
                if @param["subtype"].nil?
                  raise "validate_arguments no subtype"
                end
                raise "T0412" unless array_ok
                # the function expects an array. If it's not one, make it so
                arg = [arg] unless single == "a"
              end
            end
            validated_args.push(arg)
            arg_index += 1
          end
        end
      end
      return validated_args
    end

    raise "throwValidationError"
  end
end