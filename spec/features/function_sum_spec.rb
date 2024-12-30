require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Function -- Sum" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "$sum(Account.Order.Product.(Price * Quantity))",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq(336.36)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.$sum(Product.(Price * Quantity))",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      90.57000000000001,
      245.79000000000002
    ])
  end

  xit "case002" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.(OrderID & \": \" & $sum(Product.(Price*Quantity)))",
    )

    expect(jsonata.call(input)).to eq([
      "order103: 90.57",
      "order104: 245.79"
    ])
  end

  xit "case003" do
    jsonata, input = build_jsonata(
      expr: "$sum()",
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "$sum(1)"
    )

    expect(jsonata.call(input)).to eq(1)
  end

  xit "case005" do
    jsonata, input = build_jsonata(
      expr: "$sum(Account.Order)",
      dataset: "dataset5"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case006" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$sum(undefined)"
    )

    expect(jsonata.call(input)).to eq(nil)
  end
end