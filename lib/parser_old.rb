require "./lib/core_ext/blank"
require "./lib/jsonata_exception"
require "debug"
require "ostruct"

class Parser
  attr_accessor :errors

  OPERATORS = {
    '.' => 75,
    '[' => 80,
    ']' => 0,
    '{' => 70,
    '}' => 0,
    '(' => 80,
    ')' => 0,
    ',' => 0,
    '@' => 80,
    '#' => 80,
    ';' => 80,
    ':' => 80,
    '?' => 20,
    '+' => 50,
    '-' => 50,
    '*' => 60,
    '/' => 60,
    '%' => 60,
    '|' => 20,
    '=' => 40,
    '<' => 40,
    '>' => 40,
    '^' => 40,
    '**' => 60,
    '..' => 20,
    ':=' => 10,
    '!=' => 40,
    '<=' => 40,
    '>=' => 40,
    '~>' => 40,
    'and' => 30,
    'or' => 25,
    'in' => 40,
    '&' => 50,
    '!' => 0, # not an operator, but needed as a stop character for name tokens
    '~' => 0 # not an operator, but needed as a stop character for name tokens
  }.freeze

  # JSON string escape sequences - see json.org
  ESCAPES = {
    '"' => '"',
    '\\' => '\\',
    '/' => '/',
    'b' => '\b',
    'f' => '\f',
    'n' => '\n',
    'r' => '\r',
    't' => '\t'
  }.freeze

  def initialize(recover = nil)
    @recover = recover
    @symbol_table = {}
    @errors = []
  end

  def create_symbol(**args)
    BaseSymbol.new(recover: @recover, context: self, **args)
  end

  # Tokenizer (lexer) - invoked by the parser to return one token at a time
  def tokenizer(path)
    position = 0
    length = path.length

    create = lambda { |type, value|
      create_symbol(type: type, value: value, position: position)
    }

    scan_regex = lambda do
      start = position
      depth = 0

      is_closing_slash = lambda do |position|
        if path[position] == "/" && depth == 0
          backslash_count = 0
          while (path[position - (backslash_count + 1)]) == "\\"
            backslash_count += 1
          end
          return true if backslash_count % 2 == 0
        end
        false
      end

      while position < length
        current_char = path[position]
        if(is_closing_slash.call(position))
          pattern = path[start, position]
          if pattern == ''
            raise JsonataException.new("S0301", {position: position})
          end
          position += 1
          current_char = path[position]
          start = position
          while current_char == "i" || current_char == "m"
            position += 1
            current_char = path[position]
          end
          flags = path[start, position] + "g"
          return Regexp.new(pattern, flags)
        end

        if ["(", "[", "{",].include?(current_char) && path[position - 1] != "\\"
          depth += 1
        elsif [")", "]", "}",].include?(current_char) && path[position - 1] != "\\"
          depth -= 1
        end

        position += 1
      end

      raise JsonataException.new("S0302", {position: position})
    end

    return lambda do |prefix|
      return nil if position >= length
      current_char = path[position]
      # skip whitespace
      while position < length && "\t\n\r\v".index(current_char).present?
        position += 1
        current_char = path[position]
      end
      # skip comments
      if current_char == "/" && path[position + 1] == "*"
        comment_start = position
        position += 2
        current_char = path[position]
        while !(current_char == "*" && path[position + 1] == "/")
          position += 1
          current_char = path[position]
          if position >= length
            # no closing tag
            raise JsonataException.new("S0106", {position: comment_start})
          end
        end
      end
      # test for regex
      if prefix != true && current_char == "/"
        position += 1
        return create.call("regex", scan_regex.call)
      end
      # handle double-char operators
      if current_char = "." && path[position + 1] == "."
        # double-dot .. range operator
        position += 2
        return create.call("operator", "..")
      end
      if current_char == ":" && path[position + 1] == "="
        # := assignment
        position += 2
        return create.call("operator", ":=")
      end
      if current_char == "!" && path[position + 1] == "="
        # !=
        position += 2
        return create.call("operator", "!=")
      end
      if current_char == ">" && path[position + 1] == "="
        # >=
        position += 2
        return create.call("operator", ">=")
      end
      if current_char == "<" && path[position + 1] == "="
        # <=
        position += 2
        return create.call("operator", "<=")
      end
      if current_char == "*" && path[position + 1] == "*"
        # ** descendant wildcard
        position += 2
        return create.call("operator", "**")
      end
      if current_char == "~" && path[position + 1] == ">"
        # ~> chain function
        position += 2
        return create.call("operator", "~>")
      end
      # test for single char operators
      if OPERATORS[current_char]
        position += 1
        return create.call("operator", current_char)
      end
      if current_char == "~" && path[position + 1] == ">"
        # ~>
        position += 2
        return create.call("operator", "~>")
      end
      # test for string literals
      if current_char == "\"" || current_char == "'"
        quote_type = current_char
        # double quoted string literal - find end of string
        position += 1
        qstr = ""
        while position < length
          current_char = path[position]
          if current_char == "\\" # escape sequence
            position += 1
            current_char = path[position]
            if ESCAPES[current_char]
              qstr += ESCAPES[current_char]
            elsif current_char == "u"
              # \u should be followed by 4 hex digits
              octets = path[position + 1, 4]
              if /^[0-9a-fA-F]+$/.match(octets)
                codepoint = octets.to_i(16)
                qstr += codepoint.chr
                position += 4
              else
                raise JsonataException.new("S0104", {position: position})
              end
            end
          elsif current_char = quote_type
            position += 1
            create.call("string", qstr)
          else
            qstr += current_char
          end
        end
        raise JsonataException.new("S0101", {position: position})
      end
      # test for numbers
      numregex = /^-?(0|([1-9][0-9]*))(\.[0-9]+)?([Ee][-+]?[0-9]+)?/
      match = numregex.match(path[position])
      if match.present?
        num = match[0].to_f
        if !num.nan? && num.finite?
          position += match[0].length
          return create.call("number", num)
        else
          raise JsonataException.new("S0102", {position: position})
        end
      end
      # test for quoted names (backticks)
      name = nil
      if current_char == "`"
        # scan for closing quote
        position += 1
        end_pos = path.index("`", position)
        if end_pos != -1
          name = path[position, end_pos]
          position = end_pos + 1
          return create.call("name", name)
        end
        position = length
        raise JsonataException.new("S0105", {position: position})
      end
      # test for names
      i = position
      ch = nil
      result = nil
      while true
        ch = path[i]
        if i == length || " \t\n\r\v".index(ch).present? || OPERATORS[ch]
          if path[position] == "$"
            # variable reference
            name = path[position + 1, i]
            position = i
            result = create.call("variable", name)
          else
            name = path[position, i]
            position = i
            case name
            when "or", "in", "and"
              result = create.call("operator", name)
              break
            when "true"
              result = create.call("value", true)
              break
            when "false"
              result = create.call("value", false)
              break
            when "null", "nil"
              result = create.call("value", nil)
              break
            else
              if position == length && name == ""
                # whitespace at end of input
                result = nil
                break
              end
              result = create.call("name", name)
              break
            end
          end
        else
          i += 1
        end
      end

      result
    end
  end

  # parser implements the 'Top down operator precedence' algorithm developed by Vaughan R Pratt; http://dl.acm.org/citation.cfm?id=512931.
  # and builds on the Javascript framework described by Douglas Crockford at http://javascript.crockford.com/tdop/tdop.html
  # and in 'Beautiful Code', edited by Andy Oram and Greg Wilson, Copyright 2007 O'Reilly Media, Inc. 798-0-596-51004-6
  def parse(source)
    lexer = tokenizer(source)
    node = create_symbol

    get_symbol = lambda do |id, bp = 0|
      sym = @symbol_table[id]
      if sym.blank?
        sym = {id: id, lbp: bp, value: id}
        @symbol_table[id] = sym
      elsif bp >= sym.lbp
        sym.lbp = bp
      end
      sym
    end

    terminal = lambda { |id|
      sym = get_symbol.call(id, 0)
      sym.nud = lambda { self }
    }

    remaining_tokens = lambda {
      remaining = []
      if node.id != "end"
        remaining << create_symbol(
          type: node.type,
          value: node.value,
          position: node.position
        )
      end
      nxt = lexer.call() # TO-DO
      while !nxt.nil?
        remaining << nxt
        nxt = lexer.call() # TO-DO
      end
      remaining
    }

    handle_error = lambda do |err|
      if recover
        err.remaining = remaining_tokens.call
        errors << err
        symbol = @symbol_table["(error)"]
        node = symbol.dup || create_symbol
        node.error = err
        node.type = "(error)"
        node
      else
        throw StandardError "SAD" # TO-DO
      end
    end

    advance = lambda { |id = nil, infix = nil|
      if id && node.id != id
        code = if node.id == "(end)"
          # unexpected end of buffer
          "S0203"
        else
          "S0202"
        end
        err = OpenStruct.new(
          code: code,
          position: node.position,
          token: node.value,
          value: id
        )
        handle_error.call(err)
      end
      next_token = lexer.call(infix)
      if next_token.nil?
        node = @symbol_table["(end)"]
        node.position = source.length
        return node
      end
      value = next_token.value
      type = next_token.type
      symbol = nil
      case type
      when "name", "variable"
        symbol = @symbol_table["(name)"]
      when "operator"
        symbol = @symbol_table[value]
        unless symbol
          return handle_error.call(
            OpenStruct.new(
              code: "S0204",
              stack: Thread.current.backtrace,
              position: next_token.position,
              token: value
            )
          )
        end
      when "string", "number", "value"
        symbol = @symbol_table["(literal)"]
      when "regex"
        symbol = @symbol_table["(regex)"]
      else
        return handle_error.call(
          OpenStruct.new(
            code: "S0205",
            stack: Thread.current.backtrace,
            position: next_token.position,
            token: value
          )
        )
      end

      node = symbol.dup
      node.value = value
      node.type = type
      node.position = next_token.position
      node
    }

    # Pratt's algorithm
    expression = lambda { |rbp|
      left = nil
      t = node
      advance.call(nil, true)
      left = t.nud
      while rbp < node.lbp
        t = node
        advance.call()
        left = t.led(left)
      end
      left
    }

    # match infix operators
    # <expression> <operator> <expression>
    # left associative
    infix = lambda { |id, bp = nil, led = nil|
      binding_power = bp || OPERATORS[id]
      sym = get_symbol.call(id, binding_power)
      sym.led = led || lambda { |left|
        self.lhs = left
        self.rhs = expression.call(binding_power)
        self.type = "binary"
        self
      }
      sym
    }

    # match infix operators
    # <expression> <operator> <expression>
    # right associative
    infixr = lambda { |id, bp, led|
      sym = get_symbol.call(id, bp)
      sym.led = led
      sym
    }

    # match prefix operators
    # <operator> <expression>
    prefix = lambda { |id, nud = nil|
      sym = get_symbol.call(id)
      nud ||= lambda {
        self.expression = expression.call(70)
        self.type = "unary"
        self
      }
      sym.nud = nud
      sym
    }

    terminal.call("(end)")
    terminal.call("(name)")
    terminal.call("(literal)")
    terminal.call("(regex)")
    get_symbol.call(":")
    get_symbol.call(";")
    get_symbol.call(",")
    get_symbol.call(")")
    get_symbol.call("]")
    get_symbol.call("}")
    get_symbol.call("..") # range operator
    infix.call(".") # map operator
    infix.call("+") # numeric addition
    infix.call("-") # numeric subtraction
    infix.call("*") # numeric multiplication
    infix.call("/") # numeric division
    infix.call("%") # numeric modulus
    infix.call("=") # equality
    infix.call("<") # less than
    infix.call(">") # greater than
    infix.call("!=") # not equal to
    infix.call("<=") # less than or equal
    infix.call(">=") # greater than or equal
    infix.call("&") # string concatenation
    infix.call("and") # Boolean AND
    infix.call("or") # Boolean OR
    infix.call("in") # is member of array
    terminal.call("and") # the 'keywords' can also be used as terminals (field names)
    terminal.call("or")
    terminal.call("in")
    prefix.call("-") # unary numeric negation
    infix.call("~>") # function application

    infixr.call("(error)", 10, lambda { |left|
      self.lhs = left
      self.error = node.error
      self.remaining = remaining_tokens.call
      self.type = "error"
      self
    })

    # field wildcard (single level)
    prefix.call("*", lambda {
      self.type = "wildcard"
      self
    })

    # descendant wildcard (multi-level)
    prefix.call("**", lambda {
      self.type = "descendant"
      self
    })

    # parent operator
    prefix.call("%", lambda {
      self.type = "descparentendant"
      self
    })

    # unction invocation
    infix.call("(", OPERATORS["("], lambda { |left|
      self.lambdaedure = left
      self.type = "function"
      self.arguments = []
      if node.id != ")"
        while true
          if node.type == "operator" && node.id == "?"
            # partial function application
            self.type = "partial"
            self.arguments << node
            advance.call("?")
          else
            self.arguments << expression.call(0)
          end
          break if node.id != ","
          advance.call(",")
        end
      end
      advance.call(")", true)
      # if the name of the function is 'function' or λ, then this is function definition (lambda function)
      if left.type = "name" && (left.value == "function" || left.value == "λ")
        # all of the args must be VARIABLE tokens
        self.arguments.each.with_index(1) do |arg, index|
          if arg.type != "variable"
            return handle_error.call(
              OpenStruct.new(
                code: "S0208",
                position: arg.position,
                token: arg.value,
                value: index
              )
            )
          end
        end
        self.type = "lambda"
        # is the next token a '<' - if so, parse the function signature
        if node.id == "<"
          sig_pos = node.position
          depth = 1
          sig = "<"
          while depth > 0 && node.id != "{" && node.id != "(end)"
            tok = advance.call()
            if tok.id == ">"
              depth -= 1
            elsif tok.id == "<"
              depth += 1
            end
            sig += tok.value
          end
          advance.call(">")
          begin
            this.signature = parseSignature(sig) # TO-DO
          rescue => err
            insert the position into this error
            err.position = sig_pos + err.offset
            return handle_error.call(err)
          end
        end
        # parse the function body
        advance.call("{")
        this.body = expression.call(0)
        adance.call("}")
      end
    })

    # parenthesis - block expression
    prefix.call("(", lambda {
      expressions = []
      while node.id != ")"
        expressions << expression.call(0)
        break if node.id != ";"
        advance.call(";")
      end
      advance.call(")", true)
      self.type = "block"
      self.expressions = expressions
      self
    })

    # array constructor
    prefix.call("[", lambda {
      a = []
      if node.id != "]"
        while true
          item = expression.call(0)
          if node.id == ".."
            # range operator
            range = OpenStruct.new(
              type: "binary",
              value: "..",
              position: node.position,
              lhs: item
            )
            advance.call("..")
            range.rhs = expression.call(0)
            item = range
          end
          a << item
          break if node.id != ","
          advance.call(",")
        end
      end
      advance.call("]", true)
      self.expressions = a
      self.type = "unary"
      self
    })

    # filter - predicate or array index
    infix.call("[", OPERATORS["["], lambda {
      if node.id == "]"
        # empty predicate means maintain singleton arrays in the output
        step = left
        while step && step.type == "binary" && step.value == "["
          step = step.lhs
        end
        step.keep_array = true
        advance.call("]")
        left
      else
        self.lhs = left
        self.rhs = expression.call(OPERATORS["]"])
        self.type = "binary"
        advance.call("]", true)
        self
      end
    })

    # order-by
    infix.call("^", OPERATORS["^"], lambda {
      advance.call("(")
      terms = []
      while true
        term = OpenStruct.new(descending: false)
        if node.id == "<"
          # ascending sort
        elsif node.id == ">"
          term.descending = true
          advance.call(">")
        else
          # unspecified - default to ascending
        end
        term.expression = expression.call(0)
        terms << term
        break if node.id != ","
        advance.call(",")
      end
      advance.call(")")
      self.lhs = left
      self.rhs = terms
      self.type = "binary"
      self
    })

    object_parser = lambda { |left|
      a = []
      if node.id != "}"
        while true
          n = expression.call(0)
          advance.call(":")
          v = expression.call(0)
          a << [n, v] # holds an array of name/value expression pairs
          break if node.id != ","
          advance.call(",")
        end
      end
      advance.call("}", true)
      if left.nil?
        # NUD - unary prefix form
        self.lhs = a
        self.type = "unary"
      else
        # LED - binary infix form
        self.lhs = left
        self.rhs = a
        self.type = "binary"
      end
      self
    }

    # object constructor
    prefix.call("{", object_parser)

    # object grouping
    infix.call("{", OPERATORS["{"], object_parser)

    # bind variable
    infixr.call(":=", OPERATORS[":="], lambda { |left|
      if left.type != "variable"
        return handle_error(
          OpenStruct.new(
            code: "S0212",
            stack: Thread.current.backtrace,
            position: left.position,
            token: left.value
          )
        )
      end
      self.lhs = left
      self.rhs = expression.call(OPERATORS[":="] - 1) # subtract 1 from binding_power for right associative operators
      self.type = "binary"
      self
    })

    # focus variable bind
    infix.call("@", OPERATORS["@"], lambda { |left|
      self.lhs = left
      self.rhs = expression.call(OPERATORS["@"])
      if this.rhs.type != "variable"
        return handle_error(
          OpenStruct.new(
            code: "S0214",
            stack: Thread.current.backtrace,
            position: self.rhs.position,
            token: "@"
          )
        )
      end
      self.type = "binary"
      self
    })

    # index (position) variable bind
    infix.call("#", OPERATORS["#"], lambda { |left|
      self.lhs = left
      self.rhs = expression.call(OPERATORS["#"])
      if this.rhs.type != "variable"
        return handle_error(
          OpenStruct.new(
            code: "S0214",
            stack: Thread.current.backtrace,
            position: self.rhs.position,
            token: "#"
          )
        )
      end
    })

    # if/then/else ternary operator ?:
    infix.call("?", OPERATORS["?"], lambda { |left|
      self.type = "condition"
      self.condition = left
      self.then_proc = expression.call(0)
      if node.id == ":"
        # else condition
        advance.call(":")
        self.else = expression.call(0)
      end
      self
    })

    # object transformer
    prefix.call("|", lambda {
      self.type = "transform"
      self.pattern = expression.call(0)
      advance.call("|")
      self.update = expression.call(0)
      if node.id == ","
        advance.call(",")
        self.delete = expression.call(0)
      end
      advance.call("|")
      self
    })

    # tail call optimization
    # this is invoked by the post parser to analyse lambda functions to see
    # if they make a tail call.  If so, it is replaced by a thunk which will
    # be invoked by the trampoline loop during function application.
    # This enables tail-recursive functions to be written without growing the stack
    tail_call_optimize = lambda { |expr|
      if expr.type == "function" && !expr.predicate
        thunk = OpenStruct.new(
          type: "lambda",
          thunk: true,
          arguments: [],
          position: expr.position
        )
        thunk.body = expr
        thunk
      elsif expr.type = "condition"
        # analyse both branches
        expr.then_proc = tail_call_optimize.call(expr.then_proc)
        if expr.else.present?
          expr.else = tail_call_optimize.call(expr.else)
        end
        expr
      elsif expr.type = "block"
        # only the last expression in the block
        length = expr.expressions.length
        if length > 0
          expr.expressions[-1] = tail_call_optimize.call(expr.expressions.last)
        end
        expr
      else
        expr
      end
    }

    ancestor_label = 0
    ancestor_index = 0
    ancestry = []

    seek_parent = lambda { |node, slot|
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
          slot = seek_parent.call(node.expressions.last, slot)
        end
      when "path"
        # last step in path
        node.tuple = true
        index = node.steps.length - 1
        slot = seek_parent.call(node.steps[index -=1], slot)
        while slot.level > 0 && index >= 0
          # check previous steps
          slot = seek_parent.call(node.steps[index -=1], slot)
        end
      else
        # error - can't derive ancestor
        raise JsonataException.new("S0217", {token: node.type, position: node.position})
      end
      slot
    }

    push_ancestry = lambda { |result, value|
      if value.seeking_parent.present?
        slots = value.seeking_parent || []
        if value.type == "parent"
          slots << value.slot
        end
        if result.seeking_parent.nil?
          result.seeking_parent = slots
        else
          result.seek_parent.concat(slots)
        end
      end
    }

    resolve_ancestry = lambda { |path|
      index = path.steps.length - 1
      last_step = path.steps[index]
      slots = last_step.seeking_parent || []
      if last_step.type == "parent"
        slots << last_step.slot
      end
      slots.each do |slot|
        index = path.steps.length - 2
        while slot.level > 0
          if index > 0
            path.seeking_parent ||= []
            path.seeking_parent << slot
            break
          end
          # try previous step
          step = path.steps[index -= 1]
          while index >= 0 && step.focus && path.steps[index].focus
            step = path.steps[index -= 1]
          end
          slot = seek_parent.call(step, slot)
        end
      end
    }

    # post-parse stage
    # the purpose of this is to add as much semantic value to the parse tree as possible
    # in order to simplify the work of the evaluator.
    # This includes flattening the parts of the AST representing location paths,
    # converting them to arrays of steps which in turn may contain arrays of predicates.
    # following this, nodes containing '.' and '[' should be eliminated from the AST.
    process_ast = lambda { |expr|
      result = nil
      case expr.type
      when "binary"
        case expr.value
        when "."
          lstep = process_ast.call(expr.lhs)
          if lstep.type == "path"
            result = lstep
          else
            result = create_symbol(type: "path", steps: [lstep])
          end
          if lstep.type == "parent"
            result.seeking_parent = [lstep.slot]
          end
          rest = process_ast.call(expr.rhs)
          if rest.type == "function" &&
              rest.proedure.type == "path" &&
              rest.proedure.steps.length == 1 &&
              rest.proedure.steps[0].type == "name" &&
              result.steps.last.type == "function"
            # next function in chain of functions - will override a thenable
            result.steps[result.steps.length - 1]
          end
          if rest.type == "path"
            result.steps.concat(rest.steps)
          else
            if rest.predicate.present?
              rest.stages = rest.predicate
              rest.predicate = nil
            end
            result.steps << rest
          end
          # any steps within a path that are string literals, should be changed to 'name'
          result.steps.each do |step|
            if step.type == "number" || step.type == "value"
              # don't allow steps to be numbers or the values true/false/null
              raise JsonataException.new("S0213", {position: step.position, value: step.value})
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
            last_step.consarray.true
          end
          resolve_ancestry.call(result)
        when "["
          # predicated step
          # LHS is a step or a predicated step
          # RHS is the predicate expr
          result = process_ast.call(expr.lhs)
          step = result
          type = "predicate"
          if result.type == "path"
            step = result.steps.last
            type = "stages"
          end
          if step.group.present?
            raise JsonataException.new("S0209", {position: expr.position})
          end
          step[type] ||= []
          predicate = process_ast.call(expr.rhs)
          if predicate.seeking_parent.present?
            predicate.seeking_parent.each do |slot|
              if slot.level == 1
                seek_parent.call(step, slot)
              else
                slot.level -= 1
              end
            end
            push_ancestry(step, predicate)
          end
          step[type] << {
            type: "filter",
            expr: predicate,
            position: expr.position
          }
        when "{"
          # group-by
          # LHS is a step or a predicated step
          # RHS is the object constructor expr
          result = process_ast.call(expr.lhs)
          if result.group.present?
            raise JsonataException.new("S0210", {position: position})
          end
          # object constructor - lambdaess each pair
          result.group = create_symbol(
            lhs: expr.rhs.map { |p1, p2| [process_ast.call(p1), process_ast.call([p2])] },
            position: expr.position
          )
        when "^"
          # order-by
          # LHS is the array to be ordered
          # RHS defines the terms
          result = process_ast.call(expr.lhs)
          if result.type != "path"
            result = create_symbol(type: "path", steps: [result])
          end
          sort_step = create_symbol(type: "sort", position: expr.position)
          sort_step.terms = expr.rhs.map do |term|
            expression = process_ast.call(term.expression)
            push_ancestry.call(sort_step, expression)
            create_symbol(
              descending: term.descending,
              expression: expression
            )
          end
          result.steps << sort_step
          resolve_ancestry.call(result)
        when ":="
          result = create_symbol(type: "bind", value: expr.value, position: expr.position)
          result.lhs = process_ast.call(expr.lhs)
          result.rhs = process_ast.call(expr.rhs)
          push_ancestry(result, result.rhs)
        when "@"
          result = process_ast.call(expr.lhs)
          step = result.type == "path" ? result.steps.last : result
          # throw error if there are any predicates defined at this point
          # at this point the only type of stages can be predicates
          if step.stages.present? || step.predicate.present?
            raise JsonataException.new("S0215", {position: expr.position})
          end
          # also throw if this is applied after an 'order-by' clause
          if step.type == "sort"
            raise JsonataException.new("S0216", {position: expr.position})
          end
          step.keep_array = true if expr.keep_array
          step.tuple = true
        when "#"
          result = process_ast(expr.lhs)
          step = result
          if result.type == "path"
            step = result.steps.last
          else
            result = create_symbol(type: "path", steps: [result])
            if step.predicate.present?
              step.stages = step.predicate
              step.predicate = nil
            end
          end
          if step.stages.present?
            step.index = expr.rhs.value
          else
            step.stages << create_symbol(
              type: "index",
              value: expr.rhs.value,
              position: expr.position
            )
          end
          step.tuple = true
        when "~>"
          result = create_symbol(
            type: "apply",
            value: expr.value,
            position: expr.position
          )
          result.lhs = process_ast.call(expr.lhs)
          result.rhs = process_ast.call(expr.rhs)
          result.keep_array = result.lhs.keep_array || result.rhs.keep_array
        else
          result = create_symbol(
            type: expr.type,
            value: expr.value,
            position: expr.position
          )
          result.lhs = process_ast.call(expr.lhs)
          result.rhs = process_ast.call(expr.rhs)
          push_ancestry.call(result, result.lhs)
          push_ancestry.call(result, result.rhs)
        end
      when "unary"
      when "function", "partial"
      when "lambda"
      when "condition"
      when "transform"
      when "block"
      when "name"
      when "parent"
      when "string", "number", "value", "wildcard", "descendant", "variable", "regex"
        expr
      when "operator"
      when "error"
      else
      end
    }

    # now invoke the tokenizer and the parser and return the syntax tree
    # lexer = tokenizer(source)
    advance.call()
    # parse the tokens
    expr = expression.call(0)
    if node.id != "(end)"
      handle_error.call(JsonataException.new("S0201", {position: node.position, token: node.value}))
    end
    expr = process_ast.call(expr)
    if expr.type == "parent" || expr.seeking_parent.present?
      # error - trying to derive ancestor at top level
      raise JsonataException.new("S0217", {token: expr.type, position: expr.position})
    end

    expr.errors = errors if errors.length > 0
    expr
  end

  class BaseSymbol
    attr_accessor :recover, :id, :type, :arguments, :consarray, :keep_array, :lbp, :level, :lhs, :position, :lambdaedure, :rhs, :steps, :terms, :then, :tuple, :value
    
    def initialize(recover:, context:, id: nil, type: nil, arguments: nil, consarray: nil, keep_array: nil, lbp: 0, level: nil, lhs: nil, position: nil, lambdaedure: nil, rhs: nil, steps: nil, terms: nil, then_proc: nil, tuple: nil, value: nil)
      @recover = recover
      @context = context
      @id = id
      @type = type
      @arguments = arguments
      @consarray = consarray
      @keep_array = keep_array
      @lbp = lbp
      @level = level
      @lhs = lhs
      @position = position
      @lambdaedure = lambdaedure
      @rhs = rhs
      @steps = steps
      @terms = terms
      @then_proc = then_proc
      @tuple = tuple
      @value = value
    end
    def led=(block)
      self.define_singleton_method(:led, &block)
    end
    def nud=(arg)
      if arg.is_a?(Proc)
        self.define_singleton_method(:nud, &arg)
      else
        self.define_singleton_method(:nud) do
          arg
        end
      end
    end
    def nud # default logic before it gets overwritten with above setter
      if @recover
        err = OpenStruct.new(code: "S0211", token: value, position: position)
        # err.remaining = @remaining_tokens.call
        err.type = "error"
        @context.errors << err
        err
      else
        raise JsonataException("S0211", {token: value, position: position})
      end
    end
  end
end
