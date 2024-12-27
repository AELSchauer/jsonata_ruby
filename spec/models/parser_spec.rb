require "./lib/parser"

describe Parser do
  describe "array constructors" do
    describe "[]" do
      it "returns the expected expression and processed steps" do
        # Setup
        parser = Parser.new("[]")
        parser.setup

        # Test
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => []
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => []
        })
      end
    end

    describe "[1]" do
      it "returns the expected expression and processed steps" do
        # Setup
        parser = Parser.new("[1]")
        parser.setup

        # Test
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => [
            { "value" => 1, "type" => "number", "position" => 2 }
          ]
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => [
            { "value" => 1, "type" => "number", "position" => 2 }
          ]
        })
      end
    end

    describe "[1, \"two\",3]" do
      it "returns the expected expression and processed steps" do
        # Setup
        parser = Parser.new("[1, \"two\",3]")
        parser.setup

        # Test
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => [
            { "value" => 1, "type" => "number", "position" => 2 },
            { "value" => "two", "type" => "string", "position" => 9 },
            { "value" => 3, "type" => "number", "position" => 11 }
          ]
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => [
            { "value" => 1, "type" => "number", "position" => 2 },
            { "value" => "two", "type" => "string", "position" => 9 },
            { "value" => 3, "type" => "number", "position" => 11 }
          ]
        })
      end
    end

    describe "[1, 2, [3, 4]]" do
      it "returns the expected expression and processed steps" do
        # Setup
        parser = Parser.new("[1, 2, [3, 4]]")
        parser.setup

        # Test
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => [
            { "value" => 1, "type" => "number", "position" => 2 },
            { "value" => 2, "type" => "number", "position" => 5 },
            { 
              "type" => "unary", 
              "value" => "[",
              "position" => 8,
              "expressions" => [
                { "value" => 3, "type" => "number", "position" => 9 },
                { "value" => 4, "type" => "number", "position" => 12 }
              ]
            }
          ]
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => [
            { "value" => 1, "type" => "number", "position" => 2 },
            { "value" => 2, "type" => "number", "position" => 5 },
            { 
              "type" => "unary", 
              "value" => "[",
              "position" => 8,
              "expressions" => [
                { "value" => 3, "type" => "number", "position" => 9 },
                { "value" => 4, "type" => "number", "position" => 12 }
              ]
            }
          ]
        })
      end
    end

    describe "[foo.bar]" do
      it "returns the expected expression and processed steps" do
        # Setup
        parser = Parser.new("[foo.bar]")
        parser.setup

        # Test
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => [
            {
              "type" => "binary",
              "value" => ".",
              "position" => 5,
              "lhs" => { "value" => "foo", "type" => "name", "position" => 4 },
              "rhs" =>{ "value" => "bar", "type" => "name", "position" => 8 }
            }
          ]
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "unary",
          "value" => "[",
          "position" => 1,
          "expressions" => [
            {
              "type" => "path",
              "steps" => [
                { "value" => "foo", "type" => "name", "position" => 4 },
                { "value" => "bar", "type" => "name", "position" => 8 }
              ]
            }
          ]
        })
      end
    end

    describe "foo.blah.baz.[fud, fud]" do
      it "returns the expected expression and processed steps" do
        # Setup
        parser = Parser.new("foo.blah.baz.[fud, fud]")
        parser.setup

        # Test
        expr = parser.expression(0)
        # expect(expr.to_h).to match({
        #   "type" => "unary",
        #   "value" => "[",
        #   "position" => 1,
        #   "expressions" => [
        #     {
        #       "type" => "binary",
        #       "value" => ".",
        #       "position" => 5,
        #       "lhs" => { "value" => "foo", "type" => "name", "position" => 4 },
        #       "rhs" =>{ "value" => "bar", "type" => "name", "position" => 8 }
        #     }
        #   ]
        # })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "path",
          "steps" => [
            { "value" => "foo", "type" => "name", "position" => 3 },
            { "value" => "blah", "type" => "name", "position" => 8 },
            { "value" => "baz", "type" => "name", "position" => 12 },
            {
              "type" => "unary",
              "value" => "[",
              "position" => 14,
              "expressions" => [
                { "type" => "path", "steps" => [ { "value" => "fud", "type" => "name", "position" => 17 } ] },
                { "type" => "path", "steps" => [ { "value" => "fud", "type" => "name", "position" => 22 } ] }
              ],
              "consarray" => true
            }
          ]
        })
      end
    end

    describe "with predicate" do
      describe "[1,2,3][0]" do
        it "returns the expected expression and processed steps" do
          # Setup
          parser = Parser.new("[1,2,3][0]")
          parser.setup

          # Test
          expr = parser.expression(0)
          expect(expr.to_h).to match({
            "value" => "[",
            "type" => "binary",
            "position" => 8,
            "lhs" => {
              "value" => "[",
              "type" => "unary",
              "position" => 1,
              "expressions" => [
                { "value" => 1, "type" => "number", "position" => 2 },
                { "value" => 2, "type" => "number", "position" => 4 },
                { "value" => 3, "type" => "number", "position" => 6 }
              ]
            },
            "rhs" => { "value" => 0, "type" => "number", "position" => 9 }
          })

          expr = parser.process_ast(expr)
          expect(expr.to_h).to match({
            "type" => "unary",
            "value" => "[",
            "position" => 1,
            "expressions" => [
              { "value" => 1, "type" => "number", "position" => 2 },
              { "value" => 2, "type" => "number", "position" => 4 },
              { "value" => 3, "type" => "number", "position" => 6 }
            ],
            "predicates" => [
              {
                "type" => "filter",
                "expression" => { "value" => 0, "type" => "number", "position" => 9 },
                "position" => 8
              }
            ]
          })
        end
      end
    end
  end

  describe "boolean expressions" do
    describe "boolean only" do
      describe "true" do
        it "returns the expected expression and processed steps" do
          # Setup
          parser = Parser.new("true")
          parser.setup

          # Test
          expr = parser.expression(0)
          expect(expr.to_h).to match({
            "type" => "value",
            "value" => true,
            "position" => 4
          })
    
          expr = parser.process_ast(expr)
          expect(expr.to_h).to match({
            "type" => "value",
            "value" => true,
            "position" => 4
          })
        end
      end

      describe "false" do
        it "returns the expected expression" do
          parser = Parser.new("false")
          parser.setup

          expr = parser.expression(0)
          expect(expr.to_h).to match({
            "type" => "value",
            "value" => false,
            "position" => 5
          })

          expr = parser.process_ast(expr)
          expect(expr.to_h).to match({
            "type" => "value",
            "value" => false,
            "position" => 5
          })
        end
      end
    end

    describe "boolean with operator" do
      describe "\"and\" operator" do
        describe "true and true" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("true and true")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => "and",
              "type" => "binary",
              "position" => 8,
              "lhs" => { "value" => true, "type" => "value", "position" => 4 },
              "rhs" => { "value" => true, "type" => "value", "position" => 13 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => "and",
              "type" => "binary",
              "position" => 8,
              "lhs" => { "value" => true, "type" => "value", "position" => 4 },
              "rhs" => { "value" => true, "type" => "value", "position" => 13 }
            })
          end
        end

        describe "true and false" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("true and false")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => "and",
              "type" => "binary",
              "position" => 8,
              "lhs" => { "value" => true, "type" => "value", "position" => 4 },
              "rhs" => { "value" => false, "type" => "value", "position" => 14 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => "and",
              "type" => "binary",
              "position" => 8,
              "lhs" => { "value" => true, "type" => "value", "position" => 4 },
              "rhs" => { "value" => false, "type" => "value", "position" => 14 }
            })
          end
        end

        describe "false and true" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("false and true")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => "and",
              "type" => "binary",
              "position" => 9,
              "lhs" => { "value" => false, "type" => "value", "position" => 5 },
              "rhs" => { "value" => true, "type" => "value", "position" => 14 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => "and",
              "type" => "binary",
              "position" => 9,
              "lhs" => { "value" => false, "type" => "value", "position" => 5 },
              "rhs" => { "value" => true, "type" => "value", "position" => 14 }
            })
          end
        end

        describe "false and false" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("false and false")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => "and",
              "type" => "binary",
              "position" => 9,
              "lhs" => { "value" => false, "type" => "value", "position" => 5 },
              "rhs" => { "value" => false, "type" => "value", "position" => 15 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => "and",
              "type" => "binary",
              "position" => 9,
              "lhs" => { "value" => false, "type" => "value", "position" => 5 },
              "rhs" => { "value" => false, "type" => "value", "position" => 15 }
            })
          end
        end
      end

      describe "\"or\" operator" do
        describe "true or true" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("true or true")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => "or",
              "type" => "binary",
              "position" => 7,
              "lhs" => { "value" => true, "type" => "value", "position" => 4 },
              "rhs" => { "value" => true, "type" => "value", "position" => 12 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => "or",
              "type" => "binary",
              "position" => 7,
              "lhs" => { "value" => true, "type" => "value", "position" => 4 },
              "rhs" => { "value" => true, "type" => "value", "position" => 12 }
            })
          end
        end

        describe "true or false" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("true or false")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => "or",
              "type" => "binary",
              "position" => 7,
              "lhs" => { "value" => true, "type" => "value", "position" => 4 },
              "rhs" => { "value" => false, "type" => "value", "position" => 13 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => "or",
              "type" => "binary",
              "position" => 7,
              "lhs" => { "value" => true, "type" => "value", "position" => 4 },
              "rhs" => { "value" => false, "type" => "value", "position" => 13 }
            })
          end
        end

        describe "false or true" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("false or true")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => "or",
              "type" => "binary",
              "position" => 8,
              "lhs" => { "value" => false, "type" => "value", "position" => 5 },
              "rhs" => { "value" => true, "type" => "value", "position" => 13 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => "or",
              "type" => "binary",
              "position" => 8,
              "lhs" => { "value" => false, "type" => "value", "position" => 5 },
              "rhs" => { "value" => true, "type" => "value", "position" => 13 }
            })
          end
        end

        describe "false or false" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("false or false")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => "or",
              "type" => "binary",
              "position" => 8,
              "lhs" => { "value" => false, "type" => "value", "position" => 5 },
              "rhs" => { "value" => false, "type" => "value", "position" => 14 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => "or",
              "type" => "binary",
              "position" => 8,
              "lhs" => { "value" => false, "type" => "value", "position" => 5 },
              "rhs" => { "value" => false, "type" => "value", "position" => 14 }
            })
          end
        end
      end
    end

    describe "name with operator" do
      describe "foo and bar" do
        it "returns the expected expression and processed steps" do
          # Setup
          parser = Parser.new("foo and bar")
          parser.setup

          # Test
          expr = parser.expression(0)
          expect(expr.to_h).to match({
            "value" => "and",
            "type" => "binary",
            "position" => 7,
            "lhs" => { "value" => "foo", "type" => "name", "position" => 3 },
            "rhs" => { "value" => "bar", "type" => "name", "position" => 11 }
          })
    
          expr = parser.process_ast(expr)
          expect(expr.to_h).to match({
            "value" => "and",
            "type" => "binary",
            "position" => 7,
            "lhs" => {
              "type" => "path",
              "steps" => [ { "value" => "foo", "type" => "name", "position" => 3 } ]
            },
            "rhs" => {
              "type" => "path",
              "steps" => [ { "value" => "bar", "type" => "name", "position" => 11 } ]
            }
          })
        end
      end

      describe "and and and" do
        it "returns the expected expression and processed steps" do
          # Setup
          parser = Parser.new("and and and")
          parser.setup

          # Test
          expr = parser.expression(0)
          expect(expr.to_h).to match({
            "value" => "and",
            "type" => "binary",
            "position" => 7,
            "lhs" => { "value" => "and", "type" => "operator", "position" => 3 },
            "rhs" => { "value" => "and", "type" => "operator", "position" => 11 }
          })
    
          expr = parser.process_ast(expr)
          expect(expr.to_h).to match({
            "value" => "and",
            "type" => "binary",
            "position" => 7,
            "lhs" => {
              "type" => "path",
              "steps" => [ { "value" => "and", "type" => "name", "position" => 3 } ]
            },
            "rhs" => {
              "type" => "path",
              "steps" => [ { "value" => "and", "type" => "name", "position" => 11 } ]
            }
          })
        end
      end
    end
  end

  describe "comparison operators" do
    describe "integer to integer" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("3>-3")
        parser.setup

        ## Test      
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "value" => ">",
          "type" => "binary",
          "position" => 2,
          "lhs" => { "value" => 3, "type" => "number", "position" => 1 },
          "rhs" => {
            "value" => "-",
            "type" => "unary",
            "position" => 3,
            "expression" => { "value" => 3, "type" => "number", "position" => 4 }
          }
        })
  
        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "binary",
          "value" => ">",
          "position" => 2,
          "lhs" => { "value" => 3, "type" => "number", "position" => 1 },
          "rhs" => { "value" => -3, "type" => "number", "position" => 4 }
        })
      end
    end

    describe "string to integer" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("\"32\" < 42")
        parser.setup

        ## Test      
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "value" => "<",
          "type" => "binary",
          "position" => 6,
          "lhs" => { "value" => "32", "type" => "string", "position" => 4 },
          "rhs" => { "value" => 42, "type" => "number", "position" => 9 }
        })
  
        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "value" => "<",
          "type" => "binary",
          "position" => 6,
          "lhs" => { "value" => "32", "type" => "string", "position" => 4 },
          "rhs" => { "value" => 42, "type" => "number", "position" => 9 }
        })
      end
    end
  end

  describe "descendent operators" do
    it "returns the expected expression and processed steps" do
      ## Setup
      parser = Parser.new("foo.**.blah")
      parser.setup

      ## Test      
      expr = parser.expression(0)
      expect(expr.to_h).to match({
        "value" => ".",
        "type" => "binary",
        "position" => 7,
        "lhs" => {
          "value" => ".",
          "type" => "binary",
          "position" => 4,
          "lhs" => {
            "value" => "foo",
            "type" => "name",
            "position" => 3
          },
          "rhs" => {
            "value" => "**",
            "type" => "descendant",
            "position" => 6
          }
        },
        "rhs" => {
          "value" => "blah",
          "type" => "name",
          "position" => 11
        }
      })

      expr = parser.process_ast(expr)
      expect(expr.to_h).to match({
        "type" => "path",
        "steps" => [
          {
            "value" => "foo",
            "type" => "name",
            "position" => 3
          },
          {
            "value" => "**",
            "type" => "descendant",
            "position" => 6
          },
          {
            "value" => "blah",
            "type" => "name",
            "position" => 11
          }
        ]
      })
    end
  end

  describe "fields" do
    describe "foo" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("foo")
        parser.setup
        
        ## Test      
        expr = parser.expression(0)
        expect(expr.to_h).to match({"type"=>"name", "value"=>"foo", "position"=>3})
  
        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type"=>"path",
          "steps"=>[{"type"=>"name", "value"=>"foo", "position"=>3}]
        })
      end
    end

    describe "foo.bar" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("foo.bar")
        parser.setup
        
        ## Test      
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "type"=>"binary",
          "value"=>".",
          "position"=>4,
          "lhs"=>{"type"=>"name", "value"=>"foo", "position"=>3},
          "rhs"=>{"type"=>"name", "value"=>"bar", "position"=>7}
        })
 
        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type"=>"path",
          "steps"=>[
            {"type"=>"name", "value"=>"foo", "position"=>3},
            {"type"=>"name", "value"=>"bar", "position"=>7}
          ]
        })
      end
    end

    describe "foo.bar.bazz" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("foo.bar.bazz")
        parser.setup
        
        ## Test      
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "type"=>"binary",
          "value"=>".",
          "position"=>8,
          "lhs"=>{
            "type"=>"binary",
            "value"=>".",
            "position"=>4,
            "lhs"=>{"type"=>"name", "value"=>"foo", "position"=>3},
            "rhs"=>{"type"=>"name", "value"=>"bar", "position"=>7}
          },
          "rhs"=>{"type"=>"name", "value"=>"bazz", "position"=>12}
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type"=>"path",
          "steps"=>[
            {"type"=>"name", "value"=>"foo", "position"=>3},
            {"type"=>"name", "value"=>"bar", "position"=>7},
            {"type"=>"name", "value"=>"bazz", "position"=>12},
          ]
        })
      end
    end
  end

  describe "flattening" do
    describe "with root binding $" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("$.a[0].b")
        parser.setup

        ## Test
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "value" => ".",
          "type" => "binary",
          "position" => 7,
          "lhs" => {
            "value" => ".",
            "type" => "binary",
            "position" => 2,
            "lhs" => {
              "value" => "",
              "type" => "variable",
              "position" => 1
            },
            "rhs" => {
              "value" => "[",
              "type" => "binary",
              "position" => 4,
              "lhs" => {
                "value" => "a",
                "type" => "name",
                "position" => 3
              },
              "rhs" => {
                "value" => 0,
                "type" => "number",
                "position" => 5
              }
            }
          },
          "rhs" => {
            "value" => "b",
            "type" => "name",
            "position" => 8
          }
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "path",
          "steps" => [
            {
              "value" => "",
              "type" => "variable",
              "position" => 1
            },
            {
              "value" => "a",
              "type" => "name",
              "position" => 3,
              "stages" => [
                {
                  "type" => "filter",
                  "expression" => {
                    "value" => 0,
                    "type" => "number",
                    "position" => 5
                  },
                  "position" => 4
                }
              ]
            },
            {
              "value" => "b",
              "type" => "name",
              "position" => 8
            }
          ]
        })
      end
    end

    describe "with array wrapper" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("$.tags[title='example'][]")
        parser.setup

        ## Test
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "value" => ".",
          "type" => "binary",
          "position" => 2,
          "lhs" => {
            "value" => "",
            "type" => "variable",
            "position" => 1
          },
          "rhs" => {
            "value" => "[",
            "type" => "binary",
            "position" => 7,
            "lhs" => {
              "value" => "tags",
              "type" => "name",
              "position" => 6,
              "keep_array" => true
            },
            "rhs" => {
              "value" => "=",
              "type" => "binary",
              "position" => 13,
              "lhs" => {
                "value" => "title",
                "type" => "name",
                "position" => 12
              },
              "rhs" => {
                "value" => "example",
                "type" => "string",
                "position" => 22
              }
            }
          }
        })

        # expr = parser.process_ast(expr)
        # expect(expr.to_h).to match({
        #   "type" => "path",
        #   "steps" => [
        #     {
        #       "value" => "",
        #       "type" => "variable",
        #       "position" => 1
        #     },
        #     {
        #       "value" => "a",
        #       "type" => "name",
        #       "position" => 3,
        #       "stages" => [
        #         {
        #           "type" => "filter",
        #           "expression" => {
        #             "value" => 0,
        #             "type" => "number",
        #             "position" => 5
        #           },
        #           "position" => 4
        #         }
        #       ]
        #     },
        #     {
        #       "value" => "b",
        #       "type" => "name",
        #       "position" => 8
        #     }
        #   ]
        # })
      end
    end
  end

  describe "object constructors" do
    describe "simple key/value pairs" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("{\"key\": \"value\"}")
        parser.setup

        ## Test
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "value" => "{",
          "type" => "unary",
          "position" => 1,
          "lhs" => [
            [
              { "value" => "key", "type" => "string", "position" => 6 },
              { "value" => "value", "type" => "string", "position" => 15 }
            ]
          ]
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "value" => "{",
          "type" => "unary",
          "position" => 1,
          "lhs" => [
            [
              { "value" => "key", "type" => "string", "position" => 6 },
              { "value" => "value", "type" => "string", "position" => 15 }
            ]
          ]
        })
      end
    end

    describe "with fields and groups" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("Account.Order{OrderID: Product.\"Product Name\"}")
        parser.setup
        
        ## Test      
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "value" => "{",
          "type" => "binary",
          "position" => 14,
          "lhs" => {
            "value" => ".",
            "type" => "binary",
            "position" => 8,
            "lhs" => {
              "value" => "Account",
              "type" => "name",
              "position" => 7
            },
            "rhs" => {
              "value" => "Order",
              "type" => "name",
              "position" => 13
            }
          },
          "rhs" => [
            [
              {
                "value" => "OrderID",
                "type" => "name",
                "position" => 21
              },
              {
                "value" => ".",
                "type" => "binary",
                "position" => 31,
                "lhs" => {
                  "value" => "Product",
                  "type" => "name",
                  "position" => 30
                },
                "rhs" => {
                  "value" => "Product Name",
                  "type" => "string",
                  "position" => 45
                }
              }
            ]
          ]
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "path",
          "steps" => [
            {
              "value" => "Account",
              "type" => "name",
              "position" => 7
            },
            {
              "value" => "Order",
              "type" => "name",
              "position" => 13
            }
          ],
          "group" => {
            "lhs" => [
              [
                {
                  "type" => "path",
                  "steps" => [
                    {
                      "value" => "OrderID",
                      "type" => "name",
                      "position" => 21
                    }
                  ]
                },
                {
                  "type" => "path",
                  "steps" => [
                    {
                      "value" => "Product",
                      "type" => "name",
                      "position" => 30
                    },
                    {
                      "value" => "Product Name",
                      "type" => "name",
                      "position" => 45
                    }
                  ]
                }
              ]
            ],
            "position" => 14
          }
        })
      end
    end
  end

  describe "variables" do
    describe "variable assignment" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("$a := 5")
        parser.setup
        
        ## Test      
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "value" => ":=",
          "type" => "binary",
          "position" => 5,
          "lhs" => {
            "value" => "a",
            "type" => "variable",
            "position" => 2
          },
          "rhs" => {
            "value" => 5.0,
            "type" => "number",
            "position" => 7
          }
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "bind",
          "value" => ":=",
          "position" => 5,
          "lhs" => {
            "value" => "a",
            "type" => "variable",
            "position" => 2
          },
          "rhs" => {
            "value" => 5.0,
            "type" => "number",
            "position" => 7
          }
        })
      end
    end

    describe "variable assignment with ()" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("($a := $b := 5; $a)")
        parser.setup
        
        ## Test      
        expr = parser.expression(0)
        expect(expr.to_h).to match({
          "value" => "(",
          "type" => "block",
          "position" => 1,
          "expressions" => [
            {
              "value" => ":=",
              "type" => "binary",
              "position" => 6,
              "lhs" => {
                "value" => "a",
                "type" => "variable",
                "position" => 3
              },
              "rhs" => {
                "value" => ":=",
                "type" => "binary",
                "position" => 12,
                "lhs" => {
                  "value" => "b",
                  "type" => "variable",
                  "position" => 9
                },
                "rhs" => {
                  "value" => 5.0,
                  "type" => "number",
                  "position" => 14
                }
              }
            },
            {
              "value" => "a",
              "type" => "variable",
              "position" => 18
            }
          ]
        })

        expr = parser.process_ast(expr)
        expect(expr.to_h).to match({
          "type" => "block",
          "position" => 1,
          "expressions" => [
            {
              "type" => "bind",
              "value" => ":=",
              "position" => 6,
              "lhs" => {
                "value" => "a",
                "type" => "variable",
                "position" => 3
              },
              "rhs" => {
                "type" => "bind",
                "value" => ":=",
                "position" => 12,
                "lhs" => {
                  "value" => "b",
                  "type" => "variable",
                  "position" => 9
                },
                "rhs" => {
                  "value" => 5.0,
                  "type" => "number",
                  "position" => 14
                }
              }
            },
            {
              "value" => "a",
              "type" => "variable",
              "position" => 18
            }
          ]        
        })
      end
    end
  end
end
