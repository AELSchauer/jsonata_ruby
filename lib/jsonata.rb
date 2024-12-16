require "./lib/functions"
require "./lib/parser"
require "./lib/utils"

class Jsonata
  def initialize(expr, input, options = {})
    @input = input
    @options = options
    @parser = Parser.new(expr)
    @fn = Functions.new(context: @parser)
  end

  def call
    @expr = @parser.call
    if @input.is_a?(Array) && !Utils.get(@input, :sequence)
      @input = Utils.create_sequence(@input)
      Utils.set(@input, :outer_wrapper, true)
    end
    evaluate(@expr, @input, nil) # TO-DO
  end

  # Evaluate expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate(expr, input, environment)
    # puts [""]
    # pp ["evaluate"]
    # pp ["type:", expr.type]
    # pp ["expr:", expr.to_h]
    # pp ["input:", input]

    result = case expr.type
    when "path"
      evaluate_path(expr, input, environment)
    when "binary"
      evaluate_binary(expr, input, environment)
    when "unary"
      evaluate_unary(expr, input, environment);
    when "name"
      evaluate_name(expr, input, environment)
    when "string", "number", "value"
      expr.value
    else
      "EVALUATE #{expr.type}"
    end

    if expr.predicates.present?
      expr.predicates.each do |pred|
        result = evaluate_filter(pred.expression, result, environment)
      end
    end

    if expr.type != "path" && expr.group.present?
      # result = await evaluateGroupExpression(expr.group, result, environment);
      raise "evaluateGroupExpression"
    end

    if Utils.get(result, :sequence) && !Utils.get(result, :tuple_stream)
      Utils.set(result, :keep_singleton, true) if expr.keep_array
      if result.length <= 1
        result = Utils.get(result, :keep_singleton) ? result : result.first
      else
        result = result
      end
    end

    result 
  end

  # Evaluate binary expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_binary(expr, input, environment)
    lhs = evaluate(expr.lhs, input, environment)
    rhs = evaluate(expr.rhs, input, environment)
    op = expr.value

    if op == "and" || op == "or"
      begin
        return evaluate_boolean_expression(lhs, rhs, op)
      rescue
        raise "EVALUATE BINARY BOOLEAN ERROR"
      end
    end

    # begin
      case op
      when "+", "-", "*", "/", "%"
        raise "EVALUATE BINARY -- evaluateNumericExpression"
      when "=", "!="
        evaluate_equality_expression(lhs, rhs, op)
      when "<", "<=", ">", ">="
        evaluate_comparison_expression(lhs, rhs, op)
      when "&"
        raise "EVALUATE BINARY -- evaluateStringConcat"
      when ".."
        raise "EVALUATE BINARY -- evaluateRangeExpression"
      when "in"
        raise "EVALUATE BINARY -- evaluateIncludesExpression"
      end
    # rescue => e
    #   raise "EVALUATE BINARY EXPRESSION ERROR"
    # end
  end

  # Evaluate boolean expression against input data
  # @param {Object} lhs - LHS value
  # @param {Function} evalrhs - function to evaluate RHS value
  # @param {Object} op - opcode
  # @returns {*} Result
  def evaluate_boolean_expression(lhs, rhs, op)
    case op
    when "and"
      @fn.boolean(lhs) && @fn.boolean(rhs)
    when "or"
      @fn.boolean(lhs) || @fn.boolean(rhs)
    end
  end


  # Evaluate comparison expression against input data
  # @param {Object} lhs - LHS value
  # @param {Object} rhs - RHS value
  # @param {Object} op - opcode
  # @returns {*} Result
  def evaluate_comparison_expression(lhs, rhs, op)
    return nil if lhs.nil? || rhs.nil?

    l_comparable = lhs.is_a?(String) || lhs.is_a?(Numeric)
    r_comparable = rhs.is_a?(String) || rhs.is_a?(Numeric)

    if !l_comparable || !r_comparable
      raise "T2010"
    end

    if lhs.class != rhs.class
      raise "T2009"
    end

    case op
    when "<"
      lhs < rhs
    when "<="
      lhs <= rhs
    when ">"
      lhs > rhs
    when ">="
      lhs >= rhs
    end
  end

  # Evaluate equality expression against input data
  # @param {Object} lhs - LHS value
  # @param {Object} rhs - RHS value
  # @param {Object} op - opcode
  # @returns {*} Result
  def evaluate_equality_expression(lhs, rhs, op)
    case op
    when "="
      Utils.is_deep_equal(lhs, rhs)
    when "!="
      !Utils.is_deep_equal(lhs, rhs)
    end
  end

  # Apply filter predicate to input data
  # @param {Object} predicate - filter expression
  # @param {Object} input - Input data to a# pply predicates against
  # @param {Object} environment - Environment
  # @returns {*} Result after a# pplying predicates
  def evaluate_filter(predicate, input, environment)
    results = Utils.create_sequence
    if Utils.get(input, :tuple_stream)
      Utils.set(results, :tuple_stream, true)
    end
    input = Utils.create_sequence(input) unless input.is_a?(Array)
    if predicate.type == "number"
      index = predicate.value.floor
      item = input[index]
      if item.present?
        if item.is_a?(Array)
          results = item
        else
          results.push(item)
        end
      end
    else
      raise "EVALUTE FILTER -- not number"
    end

    results
  end

  # Evaluate name object against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_name(expr, input, environment)
    # puts [""]
    # pp ["evaluate_name"]
    # pp ["expr:", expr.to_h]
    # pp ["input:", input]
    @fn.lookup(input, expr.value)
  end

  # Evaluate path expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_path(expr, input, environment)
    # puts [""]
    # pp ["evaluate_path"]
    # pp ["expr:", expr.to_h]
    # pp ["input:", input]
    # expr is an array of steps
    # if the first step is a variable reference ($...), including root reference ($$),
    #   then the path is absolute rather than relative
    if input.is_a?(Array) && expr.steps.first.type != "variable"
      input_sequence = input
    else
      input_sequence = Utils.create_sequence(input)
    end

    result_sequence = nil
    is_tuple_stream = false
    tuple_bindings = nil

    # evaluate each step in turn
    expr.steps.each_with_index do |step, idx|
      is_tuple_stream ||= step.tuple

      # if the first step is an explicit array constructor, then just evaluate that (i.e. don't iterate over a context array)
      if idx == 0 && step.consarray
        result_sequence = evaluate(step, input_sequence, environment)
      else
        if is_tuple_stream
          # TO-DO
          raise "PANDA IS TUPLE STREAM"
        else
          # TO-DO
          result_sequence = evaluate_step(step, input_sequence, environment, idx == expr.steps.count - 1)
        end
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
    # puts [""]
    # pp ["evaluate_step"]
    # pp ["expr:", expr.to_h]
    # pp ["input:", input, Utils.get(input, :sequence), Utils.get(input, :outer_wrapper)]
    # pp ["last_step:", last_step]
    if expr.type == "sort"
      raise "EVALUATE STEP SORT"
    end

    result = Utils.create_sequence

    input.each.with_index do |input_step, idx|
      res = evaluate(expr, input_step, environment)

      # TO-DO

      result.push(res) if res.present?
    end

    result_sequence = Utils.create_sequence
    if last_step && result.length == 1 && result.first.is_a?(Array) && !Utils.get(result.first, :sequence)
      result_sequence = result.first
    else
      # flatten_sequence
      result.each do |res|
        if !res.is_a?(Array) || Utils.get(res, :cons)
          # it's not an array - just push into the result sequence
          result_sequence.push(res)
        else
          # res is a sequence - flatten it into the parent sequence
          res.each { |val| result_sequence.push(val) }
        end
      end
    end

    result_sequence
  end

  # Evaluate unary expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_unary(expr, input, environment)
    result = nil

    case expr.value
    when "-"
      raise "EVALUATE UNARY -"
    when "["
      # array constructor - evaluate each item
      result = []
      expr.expressions.each do |item|
        value = evaluate(item, input, environment)
        if value.present?
          if item.value == "["
            result.push(value)
          else
            result = @fn.append(result, value)
          end
        end
      end
      if expr.consarray
        Utils.set(result, :cons, {
          "enumerable" => false,
          "configurable" => false,
          "value" => true
        })
      end
    when "{"
      raise "EVALUATE UNARY {"
    end

    result
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
