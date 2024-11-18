module JSymbol
  class Base
    attr_reader :arguments, :consarray, :focus, :keep_array, :keep_singleton, :lbp, :level, :lhs, :lambdaedure, :rhs, :sequence, :steps, :terms, :tuple_stream, :then_proc, :tuple
    attr_accessor :lhs, :position, :rhs, :type, :value

    attr_accessor :keep_singleton_array, :seeking_parent

    def initialize(context:, recover: nil, arguments: nil, arr: nil, consarray: nil, focus: nil, keep_array: nil, keep_singleton: nil, lbp: nil, level: nil, lhs: nil, position: nil, lambdaedure: nil, rhs: nil, sequence: false, steps: nil, terms: nil, then_proc: nil, tuple: nil, tuple_stream: nil, type: nil, value: nil)
      @context = context
      @recover = recover
      @arguments = arguments
      @consarray = consarray
      @keep_array = keep_array
      @lambdaedure = lambdaedure
      @lbp = lbp
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
      # map_vars = (instance_variables - [:@context, :@recover])
      map_vars = [:@lhs, :@position, :@rhs, :@steps, :@type, :@value]
      map_vars
        .filter { |key| instance_variable_get(key).present? }
        .reduce({}) do |hsh, key|
          value = instance_variable_get(key)
          value = value.to_h if value.class.name.include?("JSymbol")
          value = value.map(&:to_h) if value.is_a?(Array)
          hsh.merge({key.to_s.sub("@", "") => value})
        end
    end

    def id
      value
    end

    def id=(arg)
      self.value = arg
    end
  end

  class Terminal < Base
    attr_accessor :lbp

    def initialize(context:, lbp: 0, type: nil, value: nil)
      super
      @lbp = lbp
    end

    def nud
      self
    end
  end

  class Infix < Base
    attr_accessor :lbp
    attr_reader :lhs, :rhs

    def initialize(context:, lbp: 0, type: nil, value: nil)
      super
      @lbp = lbp
    end

    def led(left)
      @lhs = left
      @rhs = @context.expression(@lbp)
      @type = "binary"
      self
    end
  end

  class Sequence < Base
    attr_accessor :lbp
    attr_reader :lhs, :rhs, :arr

    def initialize(context:, arr: [], lbp: 0, sequence: true, type: nil, value: nil)
      super
      @arr = arr
      @lbp = lbp
    end

    def each(&block)
      @arr.each(&block)
    end

    def empty?
      @arr.empty?
    end

    def first
      @arr.first
    end

    def length
      @arr.length
    end

    def push(arg)
      @arr.push(arg)
    end
  end

  # class Terminal < Base
  #   # attr_reader :arguments, :consarray, :keep_array, :lbp, :level, :lhs, :lambdaedure, :rhs, :steps, :terms, :then_proc, :tuple
  #   # attr_accessor :position, :type, :value
  #   attr_accessor :lbp, :position, :type, :value

  #   def initialize(context:, recover: nil, arguments: nil, consarray: nil, keep_array: nil, lbp: 0, level: nil, lhs: nil, position: nil, lambdaedure: nil, rhs: nil, steps: nil, terms: nil, then_proc: nil, tuple: nil, type: nil, value: nil)
  #     @context = context
  #     @recover = recover
  #     # @arguments = arguments
  #     # @consarray = consarray
  #     # @keep_array = keep_array
  #     # @lambdaedure = lambdaedure
  #     @lbp = lbp
  #     # @level = level
  #     # @lhs = lhs
  #     @position = position
  #     # @rhs = rhs
  #     # @steps = steps
  #     # @terms = terms
  #     # @then_proc = then_proc
  #     # @tuple = tuple
  #     @type = type
  #     @value = value
  #   end

  #   def to_h
  #     [:arguments, :consarray, :keep_array, :lbp, :level, :lhs, :lambdaedure, :position, :rhs, :steps, :terms, :then_proc, :tuple, :type, :value]
  #       .filter { |key| self.send(key).present? }
  #       .reduce({}) do |hsh, key|
  #         hsh.merge({key => self.send(key)})
  #       end
  #   end

  #   def id
  #     value
  #   end

  #   def id=(arg)
  #     self.value = arg
  #   end

  #   def led=(block)
  #     self.define_singleton_method(:led, &block)
  #   end

  #   def nud=(arg)
  #     if arg.is_a?(Proc)
  #       self.define_singleton_method(:nud, &arg)
  #     else
  #       self.define_singleton_method(:nud) do
  #         arg
  #       end
  #     end
  #   end

  #   def nud
  #     if @recover
  #       err = OpenStruct.new(code: "S0211", token: value, position: position)
  #       err.remaining = @context.remaining_tokens.call
  #       err.type = "error"
  #       @context.errors << err
  #       err
  #     else
  #       # raise JsonataException("S0211", {token: value, position: position})
  #       raise "S0211 #{value} #{position}"
  #     end
  #   end
  # end
end
