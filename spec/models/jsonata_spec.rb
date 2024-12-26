require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

describe Jsonata do
  describe "fields" do
    describe "foo" do
      it "returns the expected string" do
        ## Setup
        jsonata = Jsonata.new("foo", {"foo" => "bar"})
        
        ## Test      
        expect(jsonata.call).to match("bar")
      end

      it "returns the expected integer" do
        ## Setup
        jsonata = Jsonata.new("foo", {"foo" => 42})
        
        ## Test      
        expect(jsonata.call).to match(42)
      end

      it "returns the expected array" do
        ## Setup
        jsonata = Jsonata.new("foo", {"foo" => [4, 8, 15, 16, 23, 42]})
        
        ## Test      
        expect(jsonata.call).to match([4, 8, 15, 16, 23, 42])
      end

      it "returns the expected hash" do
        ## Setup
        jsonata = Jsonata.new("foo", {"foo" => {"bar" => "baz"}})
        
        ## Test      
        expect(jsonata.call).to match({"bar" => "baz"})
      end
    end

    describe "foo.bar" do
      it "returns the expected string" do
        ## Setup
        jsonata = Jsonata.new("foo.bar", {"foo" => {"bar" => "bazz"}})
        
        ## Test      
        expect(jsonata.call).to match("bazz")
      end

      it "returns the expected array of hashes" do
        ## Setup
        jsonata = Jsonata.new("foo.bar", {"foo" => {"bar" => [{"bazz" => "hello"}, {"bazz" => "world"}]}})
        
        ## Test      
        expect(jsonata.call).to match([{"bazz" => "hello"}, {"bazz" => "world"}])
      end
    end

    describe "foo.bar.bazz" do
      it "returns the expected string" do
        ## Setup
        jsonata = Jsonata.new("foo.bar.bazz", {"foo" => {"bar" => {"bazz" => "hello"}}})
        
        ## Test      
        expect(jsonata.call).to match("hello")
      end

      it "returns the expected array of strings" do
        ## Setup
        jsonata = Jsonata.new("foo.bar.bazz", {"foo" => {"bar" => [{"bazz" => "hello"}, {"bazz" => "world"}]}})
        
        ## Test      
        expect(jsonata.call).to match(["hello", "world"])
      end
    end
  end
end