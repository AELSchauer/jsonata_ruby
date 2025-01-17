require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

describe Jsonata do
  describe "fields" do
    describe "foo" do
      it "returns the expected string" do
        ## Setup
        jsonata, input = build_jsonata(
          expr: "foo",
          data: {"foo" => "bar"}
        )
        
        ## Test      
        expect(jsonata.call(input)).to match("bar")
      end

      it "returns the expected integer" do
        ## Setup
        jsonata, input = build_jsonata(
          expr: "foo",
          data: {"foo" => 42}
        )
        
        ## Test      
        expect(jsonata.call(input)).to match(42)
      end

      it "returns the expected array" do
        ## Setup
        jsonata, input = build_jsonata(
          expr: "foo",
          data: {"foo" => [4, 8, 15, 16, 23, 42]}
        )
        
        ## Test      
        expect(jsonata.call(input)).to match([4, 8, 15, 16, 23, 42])
      end

      it "returns the expected hash" do
        ## Setup
        jsonata, input = build_jsonata(
          expr: "foo",
          data: {"foo" => {"bar" => "baz"}}
        )
        
        ## Test      
        expect(jsonata.call(input)).to match({"bar" => "baz"})
      end
    end

    describe "foo.bar" do
      it "returns the expected string" do
        ## Setup
        jsonata, input = build_jsonata(
          expr: "foo.bar",
          data: {"foo" => {"bar" => "bazz"}}
        )
        
        ## Test      
        expect(jsonata.call(input)).to match("bazz")
      end

      it "returns the expected array of hashes" do
        ## Setup
        jsonata, input = build_jsonata(
          expr: "foo.bar",
          data: {"foo" => {"bar" => [{"bazz" => "hello"}, {"bazz" => "world"}]}}
        )
        
        ## Test      
        expect(jsonata.call(input)).to match([{"bazz" => "hello"}, {"bazz" => "world"}])
      end
    end

    describe "foo.bar.bazz" do
      it "returns the expected string" do
        ## Setup
        jsonata, input = build_jsonata(
          expr: "foo.bar.bazz",
          data: {"foo" => {"bar" => {"bazz" => "hello"}}}
        )
        
        ## Test      
        expect(jsonata.call(input)).to match("hello")
      end

      it "returns the expected array of strings" do
        ## Setup
        jsonata, input = build_jsonata(
          expr: "foo.bar.bazz",
          data: {"foo" => {"bar" => [{"bazz" => "hello"}, {"bazz" => "world"}]}}
        )
        
        ## Test      
        expect(jsonata.call(input)).to match(["hello", "world"])
      end
    end
  end
end