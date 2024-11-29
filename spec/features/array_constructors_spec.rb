require "./lib/jsonata"
require "json"

# These are test cases copied over from the source JS repo
describe "Array Constructors" do
  it "case000" do
    jsonata = build_jsonata(
      expr: "[]"
    )

    expect(jsonata.call).to eq([])
  end

  it "case001" do
    jsonata = build_jsonata(
      expr: "[1]"
    )

    expect(jsonata.call).to eq([1])
  end

  it "case002" do
    jsonata = build_jsonata(
      expr: "[1, 2]"
    )

    expect(jsonata.call).to eq([1, 2])
  end

  it "case003" do
    jsonata = build_jsonata(
      expr: "[1, 2,3]"
    )

    expect(jsonata.call).to eq([1, 2, 3])
  end

  it "case004" do
    jsonata = build_jsonata(
      expr: "[1, 2, [3, 4]]"
    )

    expect(jsonata.call).to eq([1, 2, [3, 4]])
  end

  it "case005" do
    jsonata = build_jsonata(
      expr: "[1, \"two\", [\"three\", 4]]"
    )

    expect(jsonata.call).to eq([1, "two", ["three", 4]])
  end

  it "case006" do
    ##
  end

  it "case007" do
    jsonata = build_jsonata(
      expr: "[\"foo.bar\", foo.bar, [\"foo.baz\", foo.blah.baz]]",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq([
      "foo.bar",
      42,
      [
          "foo.baz",
          {
              "fud" => "hello"
          },
          {
              "fud" => "world"
          }
      ]
    ])
  end

  it "case008" do
    jsonata = build_jsonata(
      expr: "[1, 2, 3][0]"
    )

    expect(jsonata.call).to eq(1)
  end

  it "case009" do
    jsonata = build_jsonata(
      expr: "[1, 2, [3, 4]][-1]"
    )

    expect(jsonata.call).to eq([3, 4])
  end

  it "case010" do
    jsonata = build_jsonata(
      expr: "[1, 2, [3, 4]][-1][-1]"
    )

    expect(jsonata.call).to eq(4)
  end

  it "case011" do
    jsonata = build_jsonata(
      expr: "foo.blah.baz.[fud, fud]",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq([
      [
          "hello",
          "hello"
      ],
      [
          "world",
          "world"
      ]
    ])
  end

  it "case012" do
    jsonata = build_jsonata(
      expr: "foo.blah.baz.[[fud, fud]]",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq([
        [
            [
                "hello",
                "hello"
            ]
        ],
        [
            [
                "world",
                "world"
            ]
        ]
    ])
  end

  it "case013" do
    jsonata = build_jsonata(
      expr: "foo.blah.[baz].fud",
      dataset: "dataset10"
    )

    expect(jsonata.call).to eq("hello")
  end

  it "case014" do
    jsonata = build_jsonata(
      expr: "foo.blah.[baz, buz].fud",
      dataset: "dataset10"
    )

    expect(jsonata.call).to eq([
      "hello",
      "world"
    ])
  end

  it "case015" do
    jsonata = build_jsonata(
      expr: "[Address, Other.\"Alternative.Address\"].City",
      dataset: "dataset1"
    )

    expect(jsonata.call).to eq([
      "Winchester",
      "London"
    ])
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