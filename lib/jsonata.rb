require "./lib/frame"
require "./lib/functions"
require "./lib/parser"
require "./lib/signature"
require "./lib/utils"

class Jsonata
  def initialize(expr, options = {})
    @options = options
    @parser = Parser.new(expr)
    @fn = Functions.new(context: @parser)
    setup_static_frame
    @base_env = Frame.new(@static_frame)
  end

  def call(input, bindings = {})
    @expr = @parser.call

    # If the variable bindings have been passed in, create a frame to hold these
    exec_env = bindings.blank? ? @base_env : Frame.new(@base_env, bindings)
    exec_env.bind("$", input)

    # if the input is a JSON array, then wrap it in a singleton sequence so it gets treated as a single input
    if input.is_a?(Array) && !Utils.get(input, :sequence)
      input = Utils.create_sequence(input)
      Utils.set(input, :outer_wrapper, true)
    end
    evaluate(@expr, input, exec_env)
    # TO-DO catch error
    #    // insert error message into structure
    #    populateMessage(err); // possible side-effects on `err`
    #    throw err;
  end

  # Apply procedure or function
  # @param {Object} proc - Procedure
  # @param {Array} args - Arguments
  # @param {Object} input - input
  # @param {Object} environment - environment
  # @returns {*} Result of procedure
  def apply(proc, args, input, environment)
    result = apply_inner(proc, args, input, environment)
    while Utils.is_lambda?(result) && result.thunk
      raise "APPLY is_lambda?"
    end

    result
  end

  def apply_inner(proc, args, input, environment)
    # begin
      validated_args = proc.blank? ? args : proc.signature.validate_arguments(args, input)
      if Utils.is_lambda?(proc)
        raise "APPLY INNER is_lambda?"
      elsif proc && proc.is_jsonata_function
        result = proc.implementation.call(validated_args)
        if Utils.is_iterable?(result)
          raise "APPLY INNER is_iterable?"
        end
      else
        raise "APPLY INNER is function?"
      end
    # rescue => err
    # end

    result
  end

  # Creates a function definition
  # @param {Function} method_name - Utils method name
  # @param {string} signature - JSONata function signature definition
  # @returns {{implementation: *, signature: *}} function definition
  def define_function(method_name, signature)
    JSymbol::Base.new(
      context: @parser,
      is_jsonata_function: true,
      implementation: @fn.method(method_name),
      signature: signature.nil? ? nil : Signature.new(signature)
    )
  end

  # Evaluate expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate(expr, input, environment)
    # puts ""
    # puts ["evaluate"]
    # pp ["type", expr.type]
    # pp ["expr", expr.to_h]
    # pp ["input", input]

    result = case expr.type
    when "path"
      evaluate_path(expr, input, environment)
    when "binary"
      evaluate_binary(expr, input, environment)
    when "unary"
      evaluate_unary(expr, input, environment)
    when "name"
      evaluate_name(expr, input, environment)
    when "number"
      expr.value.to_f
    when "string", "value"
      expr.value
    when "descendant"
      evaluate_descendants(expr, input)
    when "block"
      evaluate_block(expr, input, environment)
    when "bind"
      evaluate_bind_expression(expr, input, environment)
    when "function"
      evaluate_function(expr, input, environment)
    when "variable"
      evaluate_variable(expr, input, environment)
    else
      raise "EVALUATE -- #{expr.type}"
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

    # pp ["result:", result]
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
        evaluate_numeric_expression(lhs, rhs, op)
      when "=", "!="
        evaluate_equality_expression(lhs, rhs, op)
      when "<", "<=", ">", ">="
        evaluate_comparison_expression(lhs, rhs, op)
      when "&"
        raise "EVALUATE BINARY -- evaluateStringConcat"
      when ".."
        evaluate_range_expression(lhs, rhs)
      when "in"
        raise "EVALUATE BINARY -- evaluateIncludesExpression"
      end
    # rescue => e
    #   raise "EVALUATE BINARY EXPRESSION ERROR"
    # end
  end

  # Evaluate bind expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_bind_expression(expr, input, environment)
    # The RHS is the expression to evaluate
    # The LHS is the name of the variable to bind to - should be a VARIABLE token (enforced by parser)
    value = evaluate(expr.rhs, input, environment)
    environment.bind(expr.lhs.value, value)
    value
  end

  # Evaluate block against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_block(expr, input, environment)
    result = nil
    frame = Frame.new(environment)
    expr.expressions.each do |item|
      result = evaluate(item, input, frame)
    end
    result
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

  # Evaluate descendants against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @returns {*} Evaluated input data
  def evaluate_descendants(expr, input)
    result_sequence = Utils.create_sequence
    return nil if input.nil?
      
    # traverse all descendants of this object/array
    recurse_descendents(input, result_sequence)
    result_sequence.length == 1 ? result_sequence[0] : result_sequence
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
    # puts ""
    # pp ["evaluate_filter"]
    # pp ["predicate", predicate.to_h]
    # pp ["input", input]
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
      input.each.with_index do |item, idx|
        context = item
        env = environment
        if Utils.get(input, :tuple_stream)
          raise "evaluate_filter tuple stream"
        end
        res = evaluate(predicate, context, env)
        res = [res] if Utils.is_numeric?(res)
        if Utils.is_array_of_numbers?(res)
          res.each do |ires|
            ii = ires.floor
            if ii < 0
              # count in from end of array
              ii = input.length + ii
            end
            if ii == idx
              results.push(item)
            end
          end
        elsif @fn.boolean(res) ## truthy
          results.push(item)
        end 
      end
    end

    results
  end

  # Evaluate function against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_function(expr, input, environment, applyto = nil)
    # create the procedure
    # can't assume that expr.procedure is a lambda type directly
    # could be an expression that evaluates to a function (e.g. variable reference, parens expr etc.
    # evaluate it generically first, then check that it is a function.  Throw error if not.
    
    proc = evaluate(expr.procedure, input, environment)
    if proc.nil? && expr.procedure.type == "path" && environment.lookup(expr.procedure.steps[0].value)
      # help the user out here if they simply forgot the leading $
      raise "T1005"
    end

    evaluated_args = []
    evaluated_args.push(applyto.context) if applyto.present?

    # eager evaluation - evaluate the arguments
    expr.arguments.each do |arg|
      arg = evaluate(arg, input, environment)
      if Utils.is_function?(arg)
        # wrap this in a closure
        raise "evaluate_function CLOSURE"
      else
        evaluated_args.push(arg)
      end
    end

    # apply the procedure
    proc_name = expr.procedure.type == "path" ? expr.procedure.steps[0].value : expr.procedure.value
    begin
      if proc.is_a?(JSymbol::Base)
        proc.token = proc_name
        proc.position = expr.position
      end
      apply(proc, evaluated_args, input, environment)
    rescue => err
      raise "evaluate_function error"
    end
  end

  # Evaluate group expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {{}} Evaluated input data
  def evaluate_group_expression(expr, input, environment)
    result = {}
    groups = {}
    is_reduce = input.is_a?(JSymbol) && input.tuple_stream
    # group the input sequence by 'key' expression
    input = Utils.create_sequence(input) if !input.is_a?(Array)

    # if the array is empty, add a nil entry to enable literal JSON object to be generated
    input << nil if input.length.zero?

    input.each do |item|
      env = if is_reduce
        raise "createFrameFromTuple"
      else
        environment
      end

      expr.lhs.each.with_index do |pair, pair_idx|
        key = evaluate(pair[0], is_reduce ? item["@"] : item, env)

        if !key.is_a?(String) && !key.nil?
          raise "T1003"
        end

        unless key.nil?
          entry = {data: item, expr_idx: pair_idx}
          if groups[key].present?
            if groups[key][:expr_idx] != pair_idx
              raise "D1009"
            end

            # append it as an array
            groups[key][:data] = @fn.append(groups[key][:data], item)
          else
            groups[key] = entry
          end
        end
      end
    end

    # iterate over the groups to evaluate the 'value' expression
    groups.each_pair.with_index do |(key, entry), idx|
      context = entry[:data]
      env = environment
      if is_reduce
        raise "reduceTupleStream"
      end
      environment.is_parallel_call = idx > 0
      value = evaluate(expr.lhs[entry[:expr_idx]][1], context, env)
      result[key] = value
    end

    result
  end

  # Evaluate name object against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_name(expr, input, environment)
    # puts [""]
    # pp ["evaluateName"]
    # pp ["expr:", expr.to_h]
    # pp ["input:", input]
    @fn.lookup(input, expr.value)
  end

  # Evaluate numeric expression against input data
  # @param {Object} lhs - LHS value
  # @param {Object} rhs - RHS value
  # @param {Object} op - opcode
  # @returns {*} Result
  def evaluate_numeric_expression(lhs, rhs, op)
    return nil if lhs.nil? || rhs.nil?
    raise "T2001" unless Utils.is_numeric?(lhs)
    raise "T2002" unless Utils.is_numeric?(rhs)

    case op
    when "+"
      lhs + rhs
    when "-"
      lhs - rhs
    when "*"
      lhs * rhs
    when "/"
      result_float = lhs.is_a?(Float) || rhs.is_a?(Float)
      result = lhs.to_f / rhs.to_f
      !result_float && result % 1 == 0 ? result.to_i : result
    when "%"
      lhs % rhs
    end
  end

  # Evaluate path expression against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_path(expr, input, environment)
    # puts ""
    # pp ["evaluatePath"]
    # pp ["expr", expr.to_h]
    # pp ["input", input]
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
      elsif is_tuple_stream
        raise "EVALUATE -- EACH STEP -- IS TUPLE STREAM"
        # tupleBindings = await evaluateTupleStep(step, inputSequence, tupleBindings, environment);
      else
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
      raise "EVALUATE -- IS TUPLE STREAM"
    end

    if expr.keep_singleton_array
      # if the array is explicitly constructed in the expression and marked to promote singleton sequences to array
      if result_sequence.is_a?(Array) && Utils.get(result_sequence, :cons).present? && Utils.get(result_sequence, :sequence).blank?
        # result_sequence = Utils.create_sequence(result_sequence)
        raise "evaluate_path keep_singleton_array result_sequence"
      end
      Utils.set(result_sequence, :keep_singleton, true)
    end

    if expr.group.present?
      result_sequence = evaluate_group_expression(expr.group, is_tuple_stream ? tuple_bindings : result_sequence, environment)
    end

    result_sequence
  end

  # Evaluate range expression against input data
  # @param {Object} lhs - LHS value
  # @param {Object} rhs - RHS value
  # @returns {Array} Resultant array
  def evaluate_range_expression(lhs, rhs)
    return nil if lhs.nil? || rhs.nil?
    raise "T2003" if !lhs.is_a?(Numeric) || !(lhs % 1).zero?
    raise "T2004" if !rhs.is_a?(Numeric) || !(rhs % 1).zero?
    return nil if lhs > rhs 

    # limit the size of the array to ten million entries (1e7)
    # this is an implementation defined limit to protect against
    # memory and performance issues.  This value may increase in the future.
    size = rhs - lhs + 1
    raise "D2014" if size > 1e7

    result = Range.new(lhs.to_i, rhs.to_i).to_a
    Utils.set(result, :sequence, true)
    result
  end

  # Evaluate a step within a path
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @param {boolean} lastStep - flag the last step in a path
  # @returns {*} Evaluated input data
  def evaluate_step(expr, input, environment, last_step)
    # puts ""
    # pp ["evaluateStep"]
    # pp ["expr", expr.to_h]
    # pp ["input", input, Utils.get(input, :sequence), Utils.get(input, :outer_wrapper)]
    # pp ["last_step", last_step]
    if expr.type == "sort"
      raise "EVALUATE STEP SORT"
    end

    result = Utils.create_sequence

    input.each.with_index do |input_step, idx|
      res = evaluate(expr, input_step, environment)

      if expr.stages
        expr.stages.each do |stage|
          res = evaluate_filter(stage.expression, res, environment)
        end
      end

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
      result = evaluate_group_expression(expr, input, environment)
    end

    result
  end

  # Evaluate variable against input data
  # @param {Object} expr - JSONata expression
  # @param {Object} input - Input data to evaluate against
  # @param {Object} environment - Environment
  # @returns {*} Evaluated input data
  def evaluate_variable(expr, input, environment)
    # if the variable name is empty string, then it refers to context value
    if expr.value.blank?
      input.present? && Utils.get(input, :outer_wrapper) ? input[0] : input
    else
      environment.lookup(expr.value)
    end
  end

  # Recurse through descendants
  # @param {Object} input - Input data
  # @param {Object} results - Results
  def recurse_descendents(input, results)
    # this is the equivalent of //* in XPath
    if input.is_a?(Array)
      input.each do |member|
        recurse_descendents(member, results)
      end
    elsif input.is_a?(Hash)
      results.push(input)
      input.each do |ele|
        recurse_descendents(ele, results)
      end
    else
      results.push(input)
    end
  end

  def setup_static_frame
    @static_frame = Frame.new

    @static_frame.bind("sum", define_function("sum", '<a<n>:n>'));
  end
end
