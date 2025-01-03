module JSymbol
  class Base
    attr_reader :arguments, :focus, :group, :id, :keep_singleton, :level, :lhs, :procedure, :rhs, :sequence, :steps, :terms, :tuple_stream, :then_proc, :tuple
    attr_accessor :consarray, :expression, :expressions, :group, :keep_array, :lbp, :lhs, :predicates, :position, :rhs, :stages, :type, :value

    attr_accessor :keep_singleton_array, :seeking_parent

    def initialize(context:, recover: nil, arguments: nil, arr: nil, consarray: nil, expression: nil, expressions: [], group: nil, focus: nil, id: nil, keep_array: nil, keep_singleton: nil, lbp: nil, level: nil, lhs: nil, position: nil, predicates: nil, procedure: nil, rhs: nil, sequence: false, stages: nil, steps: nil, terms: nil, then_proc: nil, tuple: nil, tuple_stream: nil, type: nil, value: nil)
      @context = context
      @recover = recover
      @arguments = arguments
      @consarray = consarray
      @expression = expression
      @expressions = expressions
      @group = group
      @id = id
      @keep_array = keep_array
      @predicates = predicates
      @procedure = procedure
      @lbp = Tokenizer::INFIXES.include?(value) ? Tokenizer::OPERATORS[value] : 0
      @level = level
      @lhs = lhs
      @position = position
      @rhs = rhs
      @steps = steps
      @terms = terms
      @then_proc = then_proc
      @tuple = tuple
      @type = type
      @value = value
    end

    def to_h
      map_vars = [:@consarray, :@expression, :@lhs, :@position, :@rhs, :@predicates, :@steps, :@type, :@value, :@group, :@stages]
      map_vars.concat([:@expressions]) if @type == "unary"
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
          @rhs = @context.expression(Tokenizer::OPERATORS["]"]);
          @type = "binary";
          @context.advance("]", true);
        end
      when "{"
        @lhs = left
        @rhs = object_parser
        @type = "binary"
        # debugger
      else
        @lhs = left
        @rhs = @context.expression(@lbp)
        @type = "binary"
        # debugger
      end
      self
    end

    def nud
      case @value
      when "**"
        @type = "descendant";
      when "["
        arr = []
        if @context.node.id != "]"
          while true
            item = @context.expression(0)
            if @context.node.id == ".."
              # range operator
              range = JSymbol::Base.new(
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
