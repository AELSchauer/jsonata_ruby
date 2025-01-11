require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Function -- Join" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "$join(\"hello\")"
    )

    expect(jsonata.call(input)).to eq("hello")
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "$join([\"hello\"])"
    )

    expect(jsonata.call(input)).to eq("hello")
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "$join([\"hello\", \"world\"])"
    )

    expect(jsonata.call(input)).to eq("helloworld")
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "$join([\"hello\", \"world\"], \", \")"
    )

    expect(jsonata.call(input)).to eq("hello, world")
  end
  
  it "case004" do
    jsonata, input = build_jsonata(
      expr: "$join([], \", \")"
    )
    
    expect(jsonata.call(input)).to eq("")
  end
  
  it "case005" do
    jsonata, input = build_jsonata(
      expr: "$join(Account.Order.Product.Description.Colour, \", \")",
      dataset: "dataset5"
    )
        
    expect(jsonata.call(input)).to eq("Purple, Orange, Purple, Black")
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "$join(Account.Order.Product.Description.Colour, no.sep)",
      dataset: "dataset5"
    )
        
    expect(jsonata.call(input)).to eq("PurpleOrangePurpleBlack")
  end

  xit "case007" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$join(Account.blah.Product.Description.Colour, \", \")",
      dataset: "dataset5"
    )
        
    expect(jsonata.call(input)).to eq(nil)
  end

  xit "case008" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$join(true, \", \")"
    )

    expect { jsonata.call(input) }.to raise_error("T0412")
  end

  xit "case009" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$join([1,2,3], \", \")"
    )

    expect { jsonata.call(input) }.to raise_error("T0412")
  end

  xit "case010" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$join([\"hello\"], 3)"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case011" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$join()"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end
end