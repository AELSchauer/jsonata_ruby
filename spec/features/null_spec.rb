require "./lib/jsonata"
require "json"

# These are test cases copied over from the source JS repo
describe "Null" do
  it "case000" do
    jsonata = build_jsonata(
      expr: "null"
    )

    expect(jsonata.call).to eq(nil)
  end

  it "case001" do
    jsonata = build_jsonata(
      expr: "[null]"
    )

    expect(jsonata.call).to eq([])
  end

  it "case002" do
    jsonata = build_jsonata(
      expr: "[null, null]"
    )

    expect(jsonata.call).to eq([])
  end

  it "case003" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$not(null)"
    # )

    # expect(jsonata.call).to eq([])
  end

  it "case004" do
    jsonata = build_jsonata(
      expr: "null = null"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case005" do
    jsonata = build_jsonata(
      expr: "null != null"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case006" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "{\"true\": true, \"false\":false, \"null\": null}"
    # )

    # expect(jsonata.call).to eq({
    #   "true" => true,
    #   "false" => false,
    #   "null" => nil
    # })
  end

  # Helper setup functions
  def build_jsonata(expr:, dataset: nil, data: "")
    if dataset.present?
      Jsonata.new(expr, JSON.parse(File.read("./spec/fixtures/#{dataset}.json")))
    else
      Jsonata.new(expr, data)
    end
  end
end
