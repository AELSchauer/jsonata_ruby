module JSymbol
  class Base
    attr_reader :focus, :group, :id, :implementation, :is_jsonata_function, :keep_singleton, :level, :lhs, :name, :rhs, :sequence, :signature, :steps, :terms, :tuple_stream, :then_proc, :tuple
    attr_accessor :arguments, :consarray, :expression, :expressions, :group, :keep_array, :lbp, :lhs, :position, :predicates, :procedure, :rhs, :stages, :token, :type, :value

    attr_accessor :keep_singleton_array, :seeking_parent

    def initialize(context:, recover: nil, arguments: nil, arr: nil, consarray: nil, expression: nil, expressions: nil, group: nil, focus: nil, id: nil, implementation: nil, is_jsonata_function: false, keep_array: nil, keep_singleton: nil, lbp: nil, level: nil, lhs: nil, name: nil, position: nil, predicates: nil, procedure: nil, rhs: nil, sequence: false, stages: nil, signature: nil, steps: nil, terms: nil, then_proc: nil, token: nil, tuple: nil, tuple_stream: nil, type: nil, value: nil)
      @context = context
      @recover = recover
      @arguments = arguments
      @consarray = consarray
      @expression = expression
      @expressions = expressions
      @group = group
      @id = id
      @implementation = implementation
      @is_jsonata_function = is_jsonata_function
      @keep_array = keep_array
      @predicates = predicates
      @procedure = procedure
      @lbp = Tokenizer::INFIXES.include?(value) ? Tokenizer::OPERATORS[value] : 0
      @level = level
      @lhs = lhs
      @name = name
      @position = position
      @rhs = rhs
      @sequence = sequence
      @signature = signature
      @steps = steps
      @terms = terms
      @then_proc = then_proc
      @token = token
      @tuple = tuple
      @type = type
      @value = value
    end

    def to_h
      map_vars = [:@consarray, :@expression, :@expressions, :@keep_array, :@lhs, :@position, :@rhs, :@predicates, :@steps, :@type, :@value, :@group, :@stages]
      map_vars
        .reject { |key| instance_variable_get(key).nil? }
        .reduce({}) do |hsh, key|
          value = instance_variable_get(key)
          value = value.to_h if value.is_a?(JSymbol::Base)
          value = map_array(value) if value.is_a?(Array)
          hsh.merge({key.to_s.sub("@", "") => value})
        end
    end

    def led(left)
      case @value
      when "("
        @procedure = left
        @type = "function"
        @arguments = []
        if @context.node.id != ")"
          while true
            if @context.node.type == "operator" && @context.node.id == "?"
              # partial function application
              @type = "partial"
              @arguments.push(@context.node)
              @context.advance("?")
            else
              @arguments.push(@context.expression(0))
            end
            break if @context.node.id != ","
            @context.advance(",")
          end
        end
        @context.advance(")", true)
        # if the name of the function is 'function' or λ, then this is function definition (lambda function)
        if left.type == "name" && (left.value == "function" || left.value == "\u03BB")
          raise "JSYMBOL LED LEFT FUNCTION"
        end
      when "["
        if @context.node.id == "]"
          # empty predicate means maintain singleton arrays in the output
          step = left
          while step.present? && step.type == "binary" && step.value == "["
            step = step.lhs
          end
          step.keep_array = true
          @context.advance("]")
          return left
        else
          @lhs = left;
          @rhs = @context.expression(Tokenizer::OPERATORS["]"])
          @type = "binary";
          @context.advance("]", true);
        end
      when "{"
        @lhs = left
        @rhs = object_parser
        @type = "binary"
      when ":="
        if left.type != "variable"
          raise "S0212"
        end
        @lhs = left
        # subtract 1 from binding_power for right associative operators
        @rhs = @context.expression(Tokenizer::OPERATORS[":="] - 1)
        @type = "binary"
      else
        @lhs = left
        @rhs = @context.expression(@lbp)
        @type = "binary"
      end

      self
    end

    def nud
      case @value
      when "("
        expressions = []
        while @context.node.id != ")"
          expressions.push(@context.expression(0))
          if @context.node.id != ";"
            break
          end
          @context.advance(";")
        end
        @context.advance(")", true)
        @type = "block"
        @expressions = expressions
      when "["
        arr = []
        if @context.node.id != "]"
          while true
            item = @context.expression(0)
            if @context.node.id == ".."
              # range operator
              range = JSymbol::Base.new(
                context: @context,
                type: "binary",
                value: "..",
                position: @context.node.position,
                lhs: item
              )
              @context.advance("..")
              range.rhs = @context.expression(0)
              item = range
            end
            arr.push(item)
            break if @context.node.id != ","
            @context.advance(",")
          end
        end
        @context.advance("]", true)
        @expressions = arr
        @type = "unary"
      when "{"
        @lhs = object_parser
        @type = "unary"
      when "-"
        @expression = @context.expression(70);
        @type = "unary";
      when "**"
        @type = "descendant";
      end

      self
    end

    private

    def object_parser
      a = []
      if @context.node.id != "}"
        while true
          n = @context.expression(0)
          @context.advance(":")
          v = @context.expression(0)
          a << [n, v] # holds an array of name/value expression pairs
          break if @context.node.id != ","
          @context.advance(",")
        end
      end
      @context.advance("}", true)
      a
    end

    def map_array(arr)
      arr.map do |ele|
        ele.is_a?(Array) ? map_array(ele) : ele.to_h
      end
    end
  end
end
