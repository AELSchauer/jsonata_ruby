require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "String Concatenation" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "\"foo\" & \"bar\"",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("foobar")
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "\"foo\"&\"bar\"",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("foobar")
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "foo.blah[0].baz.fud & foo.blah[1].baz.fud",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("helloworld")
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "foo.(blah[0].baz.fud & blah[1].baz.fud)",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("helloworld")
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "foo.(blah[0].baz.fud & none)",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("hello")
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "foo.(none.here & blah[1].baz.fud)",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("world")
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "[1,2]&[3,4]",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("[1,2][3,4]")
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "[1,2]&3",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("[1,2]3")
  end

  it "case008" do
    jsonata, input = build_jsonata(
      expr: "1&2",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("12")
  end

  it "case009" do
    jsonata, input = build_jsonata(
      expr: "1&[2]",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("1[2]")
  end

  it "case010" do
    jsonata, input = build_jsonata(
      expr: "\"hello\"&5",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("hello5")
  end

  it "case011" do
    jsonata, input = build_jsonata(
      expr: "\"Prices: \" & Account.Order.Product.Price",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq("Prices: [34.45,21.67,34.45,107.99]")
  end
end
