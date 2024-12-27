require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Multiple Array Selectors" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "[1..10][[1..3,8,-1]]"
    )

    expect(jsonata.call(input)).to eq([
      2,
      3,
      4,
      9,
      10
    ])
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "[1..10][[1..3,8,5]]"
    )

    expect(jsonata.call(input)).to eq([
      2,
      3,
      4,
      6,
      9
    ])
  end

  xit "case002" do
    jsonata, input = build_jsonata(
      expr: "[1..10][[1..3,8,false]]"
    )

    expect(jsonata.call(input)).to eq([
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10
    ])
  end
end