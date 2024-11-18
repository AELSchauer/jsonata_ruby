require "./lib/parser"

describe Parser do
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
      describe "'and' operator" do
        describe "true and true" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("true and true")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => 'and',
              "type" => 'binary',
              "position" => 8,
              "lhs" => { "value" => true, "type" => 'value', "position" => 4 },
              "rhs" => { "value" => true, "type" => 'value', "position" => 13 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => 'and',
              "type" => 'binary',
              "position" => 8,
              "lhs" => { "value" => true, "type" => 'value', "position" => 4 },
              "rhs" => { "value" => true, "type" => 'value', "position" => 13 }
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
              "value" => 'and',
              "type" => 'binary',
              "position" => 8,
              "lhs" => { "value" => true, "type" => 'value', "position" => 4 },
              "rhs" => { "value" => false, "type" => 'value', "position" => 14 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => 'and',
              "type" => 'binary',
              "position" => 8,
              "lhs" => { "value" => true, "type" => 'value', "position" => 4 },
              "rhs" => { "value" => false, "type" => 'value', "position" => 14 }
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
              "value" => 'and',
              "type" => 'binary',
              "position" => 9,
              "lhs" => { "value" => false, "type" => 'value', "position" => 5 },
              "rhs" => { "value" => true, "type" => 'value', "position" => 14 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => 'and',
              "type" => 'binary',
              "position" => 9,
              "lhs" => { "value" => false, "type" => 'value', "position" => 5 },
              "rhs" => { "value" => true, "type" => 'value', "position" => 14 }
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
              "value" => 'and',
              "type" => 'binary',
              "position" => 9,
              "lhs" => { "value" => false, "type" => 'value', "position" => 5 },
              "rhs" => { "value" => false, "type" => 'value', "position" => 15 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => 'and',
              "type" => 'binary',
              "position" => 9,
              "lhs" => { "value" => false, "type" => 'value', "position" => 5 },
              "rhs" => { "value" => false, "type" => 'value', "position" => 15 }
            })
          end
        end
      end

      describe "'or' operator" do
        describe "true or true" do
          it "returns the expected expression and processed steps" do
            # Setup
            parser = Parser.new("true or true")
            parser.setup

            # Test
            expr = parser.expression(0)
            expect(expr.to_h).to match({
              "value" => 'or',
              "type" => 'binary',
              "position" => 7,
              "lhs" => { "value" => true, "type" => 'value', "position" => 4 },
              "rhs" => { "value" => true, "type" => 'value', "position" => 12 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => 'or',
              "type" => 'binary',
              "position" => 7,
              "lhs" => { "value" => true, "type" => 'value', "position" => 4 },
              "rhs" => { "value" => true, "type" => 'value', "position" => 12 }
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
              "value" => 'or',
              "type" => 'binary',
              "position" => 7,
              "lhs" => { "value" => true, "type" => 'value', "position" => 4 },
              "rhs" => { "value" => false, "type" => 'value', "position" => 13 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => 'or',
              "type" => 'binary',
              "position" => 7,
              "lhs" => { "value" => true, "type" => 'value', "position" => 4 },
              "rhs" => { "value" => false, "type" => 'value', "position" => 13 }
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
              "value" => 'or',
              "type" => 'binary',
              "position" => 8,
              "lhs" => { "value" => false, "type" => 'value', "position" => 5 },
              "rhs" => { "value" => true, "type" => 'value', "position" => 13 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => 'or',
              "type" => 'binary',
              "position" => 8,
              "lhs" => { "value" => false, "type" => 'value', "position" => 5 },
              "rhs" => { "value" => true, "type" => 'value', "position" => 13 }
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
              "value" => 'or',
              "type" => 'binary',
              "position" => 8,
              "lhs" => { "value" => false, "type" => 'value', "position" => 5 },
              "rhs" => { "value" => false, "type" => 'value', "position" => 14 }
            })
      
            expr = parser.process_ast(expr)
            expect(expr.to_h).to match({
              "value" => 'or',
              "type" => 'binary',
              "position" => 8,
              "lhs" => { "value" => false, "type" => 'value', "position" => 5 },
              "rhs" => { "value" => false, "type" => 'value', "position" => 14 }
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
            "value" => 'and',
            "type" => 'binary',
            "position" => 7,
            "lhs" => { "value" => 'foo', "type" => 'name', "position" => 3 },
            "rhs" => { "value" => 'bar', "type" => 'name', "position" => 11 }
          })
    
          expr = parser.process_ast(expr)
          expect(expr.to_h).to match({
            "value" => 'and',
            "type" => 'binary',
            "position" => 7,
            "lhs" => {
              "type" => 'path',
              "steps" => [ { "value" => 'foo', "type" => 'name', "position" => 3 } ]
            },
            "rhs" => {
              "type" => 'path',
              "steps" => [ { "value" => 'bar', "type" => 'name', "position" => 11 } ]
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
end
