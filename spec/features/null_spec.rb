require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Null" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "null"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "[null]"
    )

    expect(jsonata.call(input)).to eq([])
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "[null, null]"
    )

    expect(jsonata.call(input)).to eq([])
  end

  xit "case003" do
    jsonata, input = build_jsonata(
      expr: "$not(null)"
    )

    expect(jsonata.call(input)).to eq([])
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "null = null"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "null != null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "{\"true\": true, \"false\":false, \"null\": null}"
    )

    expect(jsonata.call(input)).to eq({
      "true" => true,
      "false" => false,
      "null" => nil
    })
  end
end
