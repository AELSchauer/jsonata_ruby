require "./lib/jsonata"
require "json"

# These are test cases copied over from the source JS repo
describe "Comparison Operators" do
  it "case000" do
    jsonata = build_jsonata(
      expr: "3>-3"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case001" do
    jsonata = build_jsonata(
      expr: "3>3"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case002" do
    ##
  end

  it "case003" do
    ##
  end

  it "case004" do
    ##
  end

  it "case005" do
    ##
  end

  it "case006" do
    ##
  end

  it "case007" do
    ##
  end

  it "case008" do
    ##
  end

  it "case009" do
    ##
  end

  it "case010" do
    ##
  end

  it "case011" do
    ##
  end

  it "case012" do
    ##
  end

  it "case013" do
    ##
  end

  it "case014" do
    ##
  end

  it "case015" do
    ##
  end

  it "case016" do
    # jsonata = build_jsonata(
    #   expr: "[Address, Other.`Alternative.Address`].City",
    #   dataset: "dataset1"
    # )

    # expect(jsonata.call).to eq([
    #   "Winchester",
    #   "London"
    # ])
  end

  it "case017" do
    # jsonata = build_jsonata(
    #   expr: "[0,1,2,3,4,5,6,7,8,9][$ % 2 = 0]",
    #   data: nil
    # )

    # expect(jsonata.call).to eq([0,2,4,6,8)
  end

  it "case018" do
    # jsonata = build_jsonata(
    #   expr: "[1, 2, 3].$",
    #   data: nil
    # )

    # expect(jsonata.call).to eq([1,2,3)
  end

  it "case019" do
    # jsonata = build_jsonata(
    #   expr: "[1, 2, 3].$",
    #   data: []
    # )

    # expect(jsonata.call).to eq([1,2,3)
  end

  it "case020" do
    # jsonata = build_jsonata(
    #   expr: "[1, 2, 3].$",
    #   data: [4,5,6]
    # )

    # expect(jsonata.call).to eq([1,2,3)
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