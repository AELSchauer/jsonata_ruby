require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Object Constructors" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "{}"
    )

    expect(jsonata.call(input)).to eq({})
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "{\"key\": \"value\"}"
    )

    expect(jsonata.call(input)).to eq({"key" => "value"})
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "{\"one\": 1, \"two\": 2}"
    )

    expect(jsonata.call(input)).to eq({"one" => 1, "two" => 2})
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "{\"one\": 1, \"two\": 2}.two"
    )

    expect(jsonata.call(input)).to eq(2)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "{\"one\": 1, \"two\": {\"three\": 3, \"four\": \"4\"}}"
    )

    expect(jsonata.call(input)).to eq({
      "one" => 1,
      "two" => {
          "three" => 3,
          "four" => "4"
      }
    })
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "{\"one\": 1, \"two\": [3, \"four\"]}"
    )

    expect(jsonata.call(input)).to eq({
      "one" => 1,
      "two" => [
        3,
        "four"
      ]
    })
  end

  xit "case006" do
    jsonata, input = build_jsonata(
      expr: "{\"test\": ()}"
    )

    expect(jsonata.call(input)).to eq({})
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "blah.{}",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  it "case008" do
    jsonata, input = build_jsonata(
      expr: "Account.Order{OrderID: Product.\"Product Name\"}",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq({
        "order103" => [
          "Bowler Hat",
          "Trilby hat"
      ],
      "order104" => [
          "Bowler Hat",
          "Cloak"
      ]
    })
  end

  it "case009" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.{OrderID: Product.\"Product Name\"}",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      {
          "order103" => [
              "Bowler Hat",
              "Trilby hat"
          ]
      },
      {
          "order104" => [
              "Bowler Hat",
              "Cloak"
          ]
      }
    ])
  end
end
