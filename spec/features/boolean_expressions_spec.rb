require "./lib/jsonata"
require "json"

# These are test cases copied over from the source JS repo
describe "Boolean Expression Datasets" do
  it "case000" do
    jsonata = build_jsonata(
      expr: "true",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case001" do
    jsonata = build_jsonata(
      expr: "false",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case002" do
    jsonata = build_jsonata(
      expr: "false or false",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case003" do
    jsonata = build_jsonata(
      expr: "false or true",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case004" do
    jsonata = build_jsonata(
      expr: "true or false",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case005" do
    jsonata = build_jsonata(
      expr: "true or true",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case006" do
    jsonata = build_jsonata(
      expr: "false and false",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case007" do
    jsonata = build_jsonata(
      expr: "false and true",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case008" do
    jsonata = build_jsonata(
      expr: "true and false",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case009" do
    jsonata = build_jsonata(
      expr: "true and true",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case010" do
    ###
  end

  it "case011" do
    ###
  end

  it "case012" do
    ###
  end

  it "case013" do
    ###
  end

  it "case014" do
    ###
  end

  it "case015" do
    jsonata = Jsonata.new("and and and", {"and" => 1, "or" => 2})

    expect(jsonata.call).to eq(true)
  end

  it "case016" do
    ###
  end

  it "case017" do
    jsonata = Jsonata.new("true or foo", "null")

    expect(jsonata.call).to eq(true)
  end

  it "case018" do
    jsonata = Jsonata.new("foo or true", "null")

    expect(jsonata.call).to eq(true)
  end

  it "case019" do
    jsonata = Jsonata.new("false or foo", "null")

    expect(jsonata.call).to eq(false)
  end

  it "case020" do
    jsonata = Jsonata.new("foo or false", "null")

    expect(jsonata.call).to eq(false)
  end

  it "case021" do
    jsonata = Jsonata.new("foo or bar", "null")

    expect(jsonata.call).to eq(false)
  end

  it "case022" do
    jsonata = Jsonata.new("true and foo", "null")

    expect(jsonata.call).to eq(false)
  end

  it "case023" do
    jsonata = Jsonata.new("foo and true", "null")

    expect(jsonata.call).to eq(false)
  end

  it "case024" do
    jsonata = Jsonata.new("false and foo", "null")

    expect(jsonata.call).to eq(false)
  end

  it "case025" do
    jsonata = Jsonata.new("foo and false", "null")

    expect(jsonata.call).to eq(false)
  end

  it "case026" do
    jsonata = Jsonata.new("foo and bar", "null")

    expect(jsonata.call).to eq(false)
  end

  it "case027" do
    ###
  end

  it "case028" do
    ###
  end

  it "case029" do
    ###
  end

  it "case030" do
    ###
  end

  # Helper setup functions
  def build_jsonata(expr:, dataset:)
    Jsonata.new(expr, JSON.parse(File.read("./spec/fixtures/#{dataset}.json")))
  end
end