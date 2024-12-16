require "./lib/core_ext/blank"
require "./lib/j_symbol"
require "debug"

class Tokenizer
  INFIXES = [
    # "-",
    "!=",
    # "?",
    ".",
    # "(",
    # "(error)",
    "[",
    # "{",
    # "@",
    # "*",
    # "/",
    # "&",
    # "#",
    # "%",
    # "^",
    # "+",
    "<",
    "<=",
    "=",
    ">",
    ">=",
    # "~>",
    "and",
    # "in",
    "or"
  ].freeze

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

  def initialize(path)
    @path = path
    @position = 0
    @length = @path.length
  end

  def tokenize(prefix = nil)
    return nil if @position >= @length
    current_char = @path[@position]

    # skip whitespace
    while @position < @length && " \t\n\r\v".index(current_char).present?
      @position += 1
      current_char = @path[@position]
    end

    # skip comments
    if current_char == "/" && @path[@position + 1] == "*"
      comment_start = @position
      @position += 2
      current_char = @path[@position]
      while !(current_char == "*" && @path[@position + 1] == "/")
        @position += 1
        current_char = @path[@position]
        if @position >= @length
          # no closing tag
          # raise JsonataException.new("S0106", {@position: comment_start})
          raise "S0106"
        end
      end
      position += 2
      current_char = @path.index(@position)
      return tokenize(prefix) # need this to swallow any following whitespace
    end

    # test for regex
    if prefix.blank? && current_char == "/"
      @position += 1
      return create("regex", scan_regex)
    end

    # handle double-char operators
    if current_char == "." && @path[@position + 1] == "."
      # double-dot .. range operator
      @position += 2
      return create("operator", "..")
    end
    if current_char == ":" && @path[@position + 1] == "="
      # := assignment
      @position += 2
      return create("operator", ":=")
    end
    if current_char == "!" && @path[@position + 1] == "="
      # !=
      @position += 2
      return create("operator", "!=")
    end
    if current_char == ":" && @path[@position + 1] == "="
      # := assignment
      @position += 2
      return create("operator", ":=")
    end
    if current_char == "!" && @path[@position + 1] == "="
      # !=
      @position += 2
      return create("operator", "!=")
    end
    if current_char == ">" && @path[@position + 1] == "="
      # >=
      @position += 2
      return create("operator", ">=")
    end
    if current_char == "<" && @path[@position + 1] == "="
      # <=
      @position += 2
      return create("operator", "<=")
    end
    if current_char == "*" && @path[@position + 1] == "*"
      # ** descendant wildcard
      @position += 2
      return create("operator", "**")
    end
    if current_char == "~" && @path[@position + 1] == ">"
      # ~> chain function
      @position += 2
      return create("operator", "~>")
    end

    # test for single char operators
    if OPERATORS[current_char].present?
      @position += 1
      return create("operator", current_char)
    end
    if current_char == "~" && @path[@position + 1] == ">"
      # ~>
      @position += 2
      return create("operator", "~>")
    end

    # test for string literals
    if current_char == "\"" || current_char == "'"
      quote_type = current_char
      # double quoted string literal - find end of string
      @position += 1
      qstr = ""
      while @position < @length
        current_char = @path[@position]
        if current_char == "\\" # escape sequence
          @position += 1
          current_char = @path[@position]
          if ESCAPES[current_char]
            qstr += ESCAPES[current_char]
          elsif current_char == "u"
            # \u should be followed by 4 hex digits
            octets = @path[@position + 1, 4]
            if /^[0-9a-fA-F]+$/.match(octets)
              codepoint = octets.to_i(16)
              qstr += codepoint.chr
              @position += 4
            else
              # raise JsonataException.new("S0104", {@position: @position})
              raise "S0104"
            end
          end
        elsif current_char == quote_type
          @position += 1
          return create("string", qstr)
        else
          qstr += current_char
        end
        @position += 1
      end
      # raise JsonataException.new("S0101", {position: @position})
      raise "S0101"
    end

    # test for numbers
    numregex = /^-?(0|([1-9][0-9]*))(\.[0-9]+)?([Ee][-+]?[0-9]+)?/
    match = numregex.match(@path[@position..-1])
    if match.present?
      num = match[0].to_f
      if !num.nan? && num.finite?
        @position += match[0].length
        num = match[0].index(".").nil? ? num.to_i : num
        return create("number", num)
      else
        # raise JsonataException.new("S0102", {position: position})
        raise "S0102"
      end
    end

    # test for quoted names (backticks)
    name = nil
    if current_char == "`"
      # scan for closing quote
      @position += 1
      end_pos = @path.index("`", @position)
      if end_pos != -1
        name = @path[@position, end_pos]
        @position = end_pos + 1
        return create("name", name)
      end
      @position = @length
      # raise JsonataException.new("S0105", {position: @position})
      raise "S0105"
    end

    # test for names
    i = @position
    ch = nil
    result = nil
    while result.nil?
      ch = @path[i]

      if i == @length || " \t\n\r\v".index(ch).present? || OPERATORS[ch].present?
        if @path[@position] == "$"
          # variable reference
          name = @path[@position + 1, i]
          @position = i
          result = create("variable", name)
        else
          name = @path[@position, i - @position]
          @position = i
          case name
          when "or", "in", "and"
            result = create("operator", name)
          when "true"
            result = create("value", true)
          when "false"
            result = create("value", false)
          when "null", "nil"
            result = create("value", nil)
          else
            if @position == @length && name == ""
              # whitespace at end of input
              result = nil
            end
            result = create("name", name)
          end
        end
      else
        i += 1
      end
    end

    result
  end

  def create(type, value)
    JSymbol::Base.new(
      recover: @recover,
      context: self,
      type: type,
      value: value,
      position: @position
    )
  end

  def scan_regex
    start = @position
    depth = 0

    while @position < @length
      current_char = @path[@position]
      if is_closing_slash(@position, depth)
        pattern = @path[start, @position]
        if pattern.blank?
          # raise JsonataException.new("S0301", {@position: @position})
          raise "S0301"
        end

        @position += 1
        current_char = @path[@position]
        start = @position
        while current_char == "i" || current_char == "m"
          @position += 1
          current_char = @path[@position]
        end

        flags = @path[start, @position] + "g"
        return Regexp.new(pattern, flags)
      end

      if ["(", "[", "{",].include?(current_char) && @path[@position - 1] != "\\"
        depth += 1
      elsif [")", "]", "}",].include?(current_char) && @path[@position - 1] != "\\"
        depth -= 1
      end

      @position += 1
    end

    raise "S0302"
  end

  def is_closing_slash(position, depth)
    return false unless @path[@position] == "/" && depth == 0

    backslash_count = 0
    while (@path[@position - (backslash_count + 1)]) == "\\"
      backslash_count += 1
    end

    backslash_count % 2 == 0
  end
end