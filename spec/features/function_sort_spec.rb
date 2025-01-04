require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Function -- Sort" do
  xit "case000" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$sort(nothing)"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "$sort(1)"
    )

    expect(jsonata.call(input)).to eq([1.0])
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "$sort([1,3,2])"
    )

    expect(jsonata.call(input)).to eq([1,2,3])
  end

  xit "case003" do
    jsonata, input = build_jsonata(
      expr: "$sort([1,3,22,11])"
    )

    expect(jsonata.call(input)).to eq([1,3,11,22])
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "[[$], [$sort($)], [$]]",
      data: [
        1,
        3,
        2
      ]
    )

    expect(jsonata.call(input)).to eq([
      [1,3,2],
      [1,2,3],
      [1,3,2]
    ])
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "$sort(Account.Order.Product.Price)",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      21.67,
      34.45,
      34.45,
      107.99
    ])
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "$sort(Account.Order.Product.\"Product Name\")",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      "Bowler Hat",
      "Bowler Hat",
      "Cloak",
      "Trilby hat"
    ])
  end

  xit "case007" do
    jsonata, input = build_jsonata(
      expr: "$sort(Account.Order.Product)",
      dataset: "dataset5"
    )

    expect { jsonata.call(input) }.to raise_error("D3070")
  end

  xit "case008" do
    jsonata, input = build_jsonata(
      expr: "$sort(Account.Order.Product, function($a, $b) { $a.(Price * Quantity) > $b.(Price * Quantity) }).(Price & \" x \" & Quantity)",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      "21.67 x 1",
      "34.45 x 2",
      "107.99 x 1",
      "34.45 x 4"
    ])
  end

  xit "case009" do
    jsonata, input = build_jsonata(
      expr: "$sort(Account.Order.Product, function($a, $b) { $a.(Price * Quantity) > $b.(Price * Quantity) }).(Price & \" x \" & Quantity)",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      "0406634348",
      "0406654608",
      "040657863",
      "0406654603"
    ])
  end

  xit "case010" do
    jsonata, input = build_jsonata(
      expr: "\n                (Account.Order.Product\n                  ~> $sort(λ($a,$b){$a.Quantity < $b.Quantity})\n                  ~> $sort(λ($a,$b){$a.Price > $b.Price})\n                ).SKU\n            ",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      "0406634348",
      "040657863",
      "0406654608",
      "0406654603"
    ])
  end
end