require "./lib/functions"
require "./lib/parser"
require "./lib/utils"

class Jsonata
  def initialize(expr, input, options = {})
    @input = input
    @options = options
    @parser = Parser.new(expr)
    @functions = Functions.new(context: @parser)
  end

  def call
    @expr = @parser.call
    evaluate(@expr, @input, nil) # TO-DO
  end

  # Evaluate expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate(expr, input, environment)
    result = case expr.type
    when "path"
      evaluate_path(expr, input, environment)
    when "name"
      evaluate_name(expr, input, environment)
    end

    if Utils.is_sequence?(result) && !result.tuple_stream
      result.keep_singleton = true if expr.keep_array
      if result.length <= 1
        result = result.keep_singleton ? result : result.first
      else
        result = result.arr
      end
    end

    result 
  end

  # Evaluate name object against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_name(expr, input, environment)
    @functions.lookup(input, expr.value)
  end

  # Evaluate path expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_path(expr, input, environment)
    # expr is an array of steps
    # if the first step is a variable reference ($...), including root reference ($$),
    #   then the path is absolute rather than relative
    if Utils.is_sequence?(input) && expr.steps.first.type != "variable"
      input_sequence = input
    else
      input_sequence = JSymbol::Sequence.new(context: @parser, arr: [input])
    end

    result_sequence = nil
    is_tuple_stream = false
    tuple_bindings = nil

    # evaluate each step in turn
    expr.steps.each_with_index do |step, idx|
      is_tuple_stream ||= step.tuple

      # if the first step is an explicit array constructor, then just evaluate that (i.e. don't iterate over a context array)
      if idx == 0 && step.consarray
        result_sequence = evaluate_step(step, input_sequence, environment)
      elsif is_tuple_stream
        # TO-DO
        raise "PANDA IS TUPLE STREAM"
      else
        # TO-DO
        result_sequence = evaluate_step(step, input_sequence, environment, idx == expr.steps.count - 1)
      end

      if !is_tuple_stream && (result_sequence.nil? || result_sequence.empty?)
        break
      end

      if step.focus.nil?
        input_sequence = result_sequence
      end
    end

    if is_tuple_stream
      raise "PANDA 2"
    end

    if expr.keep_singleton_array
      raise "PANDA 3"
    end

    result_sequence
  end

  # Evaluate a step within a path
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @param {boolean} lastStep - flag the last step in a path
  # @returns {*} Evaluated input data
  def evaluate_step(expr, input, environment, last_step)
    result = nil

    result = JSymbol::Sequence.new(context: @parser)

    input.each.with_index do |input_step, idx|
      res = evaluate(expr, input_step, environment)

      # TO-DO

      result.push(res) if res.present?
    end

    result_sequence = JSymbol::Sequence.new(context: @parser)
    if last_step.present? && result.length == 1 && Utils.is_sequence?(result.first)
      result_sequence = result.first
    else
      # flatten_sequence
      result.each do |res|
        if Utils.is_sequence?(res)
          res.each { |val| result_sequence.push(val) }
        else
          result_sequence.push(res)
        end
      end
    end

    result_sequence
  end

  # Create frame
  # @param {Object} enclosingEnvironment - Enclosing environment
  # @returns {{bind: bind, lookup: lookup}} Created frame
  class Frame
    def initialize(enclosing_environment)
      @enclosing_environment = enclosing_environment
      @bindings = {}
    end

    def bind(name, value)
      name = name.to_s
      return nil if name == ""
      @bindings[name] = value
    end

    def lookup(name)
      name = name.to_s
      @bindings[name] || @enclosing_environment.lookup(name)
    end

    def timestamp
      @enclosing_environment&.timestamp || nil
    end

    def global
      @enclosing_environment&.global || {"ancestry" => [nil]}
    end
  end
end
