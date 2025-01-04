require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Function -- Floor" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "$floor(3.7)"
    )

    expect(jsonata.call(input)).to eq(3.0)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "$floor(-3.7)",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq(-4.0)
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "$floor(0)",
    )

    expect(jsonata.call(input)).to eq(0)
  end

  xit "case003" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$floor(nothing)",
    )

    expect(jsonata.call(input)).to eq(nil)
  end
end