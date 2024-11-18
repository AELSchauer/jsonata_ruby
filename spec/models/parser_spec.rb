require "./lib/parser"

describe Parser do
  describe "fields" do
    describe "foo" do
      it "returns the expected expression and processed steps" do
        ## Setup
        parser = Parser.new("foo")
        parser.terminal("(end)")
        parser.terminal("(name)")
        parser.infix(".")
        parser.advance
        
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
        parser.terminal("(end)")
        parser.terminal("(name)")
        parser.infix(".")
        parser.advance
        
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
        parser.terminal("(end)")
        parser.terminal("(name)")
        parser.infix(".")
        parser.advance
        
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
