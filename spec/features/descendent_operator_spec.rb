require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Descendent Operator" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "foo.**.blah",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      {
        "baz" => {
          "fud" => "hello"
        }
      },
      {
        "baz" => {
          "fud" => "world"
        }
      },
      {
        "bazz" => "gotcha"
      }
    ])
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "foo.**.baz",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      {
        "fud" => "hello"
      },
      {
        "fud" => "world"
      }
    ])
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "foo.**.fud",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      "hello",
      "world"
    ])
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "\"foo\".**.fud",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      "hello",
      "world"
    ])
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "foo.**.\"fud\"",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      "hello",
      "world"
    ])
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "\"foo\".**.\"fud\"",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      "hello",
      "world"
    ])
  end

  xit "case006" do
    jsonata, input = build_jsonata(
      expr: "foo.*.**.fud",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      "hello",
      "world"
    ])
  end

  xit "case007" do
    jsonata, input = build_jsonata(
      expr: "foo.**.*.fud",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      "hello",
      "world"
    ])
  end

  it "case008" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.**.Colour",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      "Purple",
      "Orange",
      "Purple",
      "Black"
    ])
  end

  it "case009" do
    jsonata, input = build_jsonata(
      expr: "foo.**.fud[0]",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      "hello",
      "world"
    ])
  end

  xit "case010" do
    jsonata, input = build_jsonata(
      expr: "(foo.**.fud)[0]",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("hello")
  end

  xit "case011" do
    jsonata, input = build_jsonata(
      expr: "(**.fud)[0]",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq("hello")
  end

  it "case012" do
    jsonata, input = build_jsonata(
      expr: "**.Price",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      34.45,
      21.67,
      34.45,
      107.99
    ])
  end

  it "case013" do
    jsonata, input = build_jsonata(
      expr: "**.Price[0]",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      34.45,
      21.67,
      34.45,
      107.99
    ])
  end

  xit "case014" do
    jsonata, input = build_jsonata(
      expr: "(**.Price)[0]",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq(34.45)
  end

  xit "case015" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "Account.Order.blah.**",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  xit "case016" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "**",
    )

    expect(jsonata.call(input)).to eq(nil)
  end
end
