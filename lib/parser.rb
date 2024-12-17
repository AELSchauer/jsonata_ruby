require "./lib/tokenizer"
require "./lib/j_symbol"
require "debug"

class Parser
  attr_reader :node

  def initialize(source)
    @source = source
    @lexer = Tokenizer.new(source)
    @node = JSymbol::Base.new(context: self)
    @symbol_table = {}
  end

  def call
    setup

    # parse the token
    expr = expression(0)

    if @node.id != "(end)"
      raise "S0201"
    end

    expr = process_ast(expr)

    if expr.type == "parent" || expr.seeking_parent.present?
      # error - trying to derive ancestor at top level
      raise "S0217"
    end

    expr
  end

  def setup
    # Terminal
    symbol("(end)")
    symbol("(name)")
    symbol("(literal)")
    symbol("and") # the 'keywords' can also be used as terminals (field names)
    symbol("or")

    # Base Symbol
    symbol(",")
    symbol("]")

    # Infix Only
    symbol(".") # map operator
    symbol("+") # numeric addition
    symbol("*") # numeric multiplication
    symbol("/") # numeric division
    symbol("%") # numeric modulus
    symbol("=") # equal to
    symbol(">") # greater than
    symbol("<") # less than
    symbol("!=") # not equal to
    symbol(">=") # greater than or equal to
    symbol("<=") # less than or equal to
    symbol("and") # Boolean AND
    symbol("or") # Boolean OR

    # Infix and Prefix
    symbol("[") # array constructor & filter - predicate or array index
    symbol("-") # numeric subtraction & unary numeric negation

    advance
  end

  def advance(id = nil, infix = nil)
    if id.present? && @node.id != id
      code = if @node.id == "(end)"
        # unexpected end of buffer
        "S0203"
      else
        "S0202"
      end
      raise code
    end

    next_token = @lexer.tokenize(infix)
    if next_token.nil?
      @node = @symbol_table["(end)"]
      @node.position = @source.length
      return @node
    end

    value = next_token.value
    type = next_token.type
    sym = nil
    case type
    when "name", "variable"
      sym = @symbol_table["(name)"]
    when "operator"
      sym = @symbol_table[value]
      if sym.blank?
        raise "S0204 -- #{value}"
      end
    when "string", "number", "value"
      sym = @symbol_table["(literal)"]
    when "regex"
      #
    else
      #
    end

    @node = sym.dup
    @node.value = value
    @node.type = type
    @node.position = next_token.position
    @node
  end

  def expression(rbp)
    left = nil
    t = @node
    advance(nil, true)
    left = t.nud
    while rbp < @node.lbp
      t = @node
      advance()
      left = t.led(left)
    end
    left
  end

  def process_ast(expr)
    result = nil
    case expr.type
    when "binary"
      case expr.value
      when "."
        lstep = process_ast(expr.lhs)
        result = if lstep.type == "path"
          lstep
        else
          JSymbol::Base.new(context: self, type: "path", steps: [lstep])
        end
        result.seeking_parent = [lstep.slot] if lstep.type == "parent"
        rest = process_ast(expr.rhs)
        if rest.type == "function"
          raise "FUNCTION TODO"
        end
        ## TODO
        # if rest.type == "function" &&
        #     rest.proedure.type == "path" &&
        #     rest.proedure.steps.length == 1 &&
        #     rest.proedure.steps[0].type == "name" &&
        #     result.steps.last.type == "function"
        #   # next function in chain of functions - will override a thenable
        #   result.steps[result.steps.length - 1]
        # end
        if rest.type == "path"
          result.steps.concat(rest.steps)
        else
          if rest.predicates.present?
            rest.stages = rest.predicates
            rest.predicates = nil
          end
          result.steps.push(rest)
        end

        # any steps within a path that are string literals, should be changed to 'name'
        result.steps.each do |step|
          if step.type == "number" || step.type == "value"
            # don't allow steps to be numbers or the values true/false/null
            # raise JsonataException.new("S0213", {position: step.position, value: step.value})
            raise "S0213"
          elsif step.type == "string"
            step.type = "name"
          end
        end

        # any step that signals keeping a singleton array, should be flagged on the path
        first_step = result.steps[0]
        if first_step.type == "unary" && first_step.value == "["
          first_step.consarray = true
        end

        # if the last step is an array constructor, flag it so it doesn't flatten
        last_step = result.steps.last
        if last_step.type == "unary" && last_step.value == "["
          last_step.consarray = true
        end

        resolve_ancestry(result)
      when "["
        # predicated step
        # LHS is a step or a predicated step
        # RHS is the predicate expr
        result = process_ast(expr.lhs)
        if result.type == "path"
          step = result.steps.last
          step.stages ||= []
          arr = step.stages
        else
          step = result
          step.predicates ||= []
          arr = step.predicates
        end
        if step.group.present?
          raise "S0209"
        end
        predicate = process_ast(expr.rhs)
        if predicate.seeking_parent.present?
          raise "BINARY [ SEEKING PARENT"
          # predicate.seekingParent.forEach(slot => {
          #     if(slot.level === 1) {
          #         seekParent(step, slot);
          #     } else {
          #         slot.level--;
          #     }
          # });
          # pushAncestry(step, predicate);
        end
        arr.push(
          JSymbol::Base.new(
            context: self,
            type: "filter",
            expression: predicate,
            position: expr.position
          )
        )
      when "{"
        raise "BINARY {"
      when "^"
        raise "BINARY ^"
      when ":="
        raise "BINARY :="
      when "@"
        raise "BINARY @"
      when "#"
        raise "BINARY #"
      when "~>"
        raise "BINARY ~>"
      else
        result = JSymbol::Base.new(
          context: self,
          type: expr.type,
          value: expr.value,
          position: expr.position,
          lhs: process_ast(expr.lhs),
          rhs: process_ast(expr.rhs)
        )
        push_ancestry(result, result.lhs)
        push_ancestry(result, result.rhs)
      end
    when "unary"
      result = JSymbol::Base.new(
        context: self,
        type: expr.type,
        value: expr.value,
        position: expr.position
      )
      if expr.value == "["
        result.expressions = expr.expressions.map do |item|
          value = process_ast(item)
          push_ancestry(result, value)
          value
        end
      elsif expr.value == "{"
        raise "UNARY -- object constructor - process each pair"
      else
        result.expression = process_ast(expr.expression)
        # if unary minus on a number, then pre-process
        if expr.value == "-" && result.expression.type == "number"
          result = result.expression
          result.value = -result.value
        else
          push_ancestry(result, result.expression)
        end
      end
    when "function", "partial"
      raise "FUNCTION / PARTIAL"
    when "lambda"
      raise "LAMBDA"
    when "condition"
      raise "CONDITION"
    when "transform"
      raise "TRANSFORM"
    when "block"
    when "name"
      result = JSymbol::Base.new(context: self, type: "path", steps: [expr])
      result.keep_singleton_array = expr.keep_array
    when "parent"
    when "string", "number", "value", "wildcard", "descendant", "variable", "regex"
      result = expr
    when "operator"
      # the tokens 'and' and 'or' might have been used as a name rather than an operator
      if %w(and or in).include?(expr.value)
        expr.type = "name"
        result = process_ast(expr)
      elsif expr.value == "?"
        raise "OPERATOR ?"
      else
        raise "S0201"
      end
    end

    result
  end

  def push_ancestry(result, value)
    if value.seeking_parent.present? || value.type == "parent"
      raise "PUSH ANCESTRY"
    end
  end

  def resolve_ancestry(path)
    index = path.steps.length - 1
    last_step = path.steps.last
    slots = last_step.seeking_parent || []

    if last_step.type == "parent"
      slots.push(last_step.slot)
    end

    slots.each do |slot|
      index = path.steps.length - 2
      while slot.level > 0
        if index > 0
          path.seeking_parent ||= []
          path.seeking_parent.push(slot)
          break
        end

        # try previous step
        step = path.steps[index -= 1]
        while index >= 0 && step.focus && path.steps[index].focus
          step = path.steps[index -= 1]
        end
        slot = seek_parent(step, slot)
      end
    end
  end

  def seek_parent(node, slot)
    case node.type
    when "name", "wildcard"
      slot.level -= 1
      if slot.level == 0
        if node.ancestor.nil?
          node.ancestor = slot
        else
          # reuse the existing label
          ancestry[slot.level].slot.label = node.ancestor.label
          node.ancestor.slot
        end
        node.tuple = true
      end
    when "parent"
      slot.level += 1
    when "block"
      # look in last expression in the block
      if node.expressions.length > 0
        node.tuple = true
        slot = seek_parent(node.expressions.last, slot)
      end
    when "path"
      # last step in path
      node.tuple = true
      index = node.steps.length - 1
      slot = seek_parent(node.steps[index -=1], slot)
      while slot.level > 0 && index >= 0
        # check previous steps
        slot = seek_parent(node.steps[index -=1], slot)
      end
    else
      # error - can't derive ancestor
      # raise JsonataException.new("S0217", {token: node.type, position: node.position})
      raise "S0217"
    end
    slot
  end

  def symbol(id, bp = 0)
    sym = @symbol_table[id]
    if sym.blank?
      sym = JSymbol::Base.new(context: self, lbp: bp, id: id, value: id)
      @symbol_table[id] = sym
    elsif bp >= sym.lbp
      sym.lbp = bp
    end
    sym
  end

  def symbol_table
    @symbol_table.transform_values(&:to_h)
  end

  def terminal(id)
    symbol(id, 0)
  end
end
