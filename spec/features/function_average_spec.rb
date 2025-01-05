require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Function -- Average" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "$average(Account.Order.Product.(Price * Quantity))",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq(84.09)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.$average(Product.(Price * Quantity))",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      45.285,
      122.895
    ])
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.(OrderID & \": \" & $average(Product.(Price*Quantity)))",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      "order103: 45.285",
      "order104: 122.895"
    ])
  end

  it "case003" do
    # undefined result
    jsonata, input = build_jsonata(
      expr: "$average([])"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "$average([1,2,3])"
    )

    expect(jsonata.call(input)).to eq(2)
  end

  xit "case005" do
    jsonata, input = build_jsonata(
      expr: "$average([\"1\"\"2\"\"3\"])",
      dataset: "dataset5"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case006" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "$average([\"1\"\"2\"3])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "$average(1)"
    )

    expect(jsonata.call(input)).to eq(1)
  end

  xit "case008" do
    jsonata, input = build_jsonata(
      expr: "$average([],[])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case009" do
    jsonata, input = build_jsonata(
      expr: "$average([1,2,3],[])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case010" do
    jsonata, input = build_jsonata(
      expr: "$average([],[],[])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case011" do
    jsonata, input = build_jsonata(
      expr: "$average([1,2],[],[])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case011" do
    jsonata, input = build_jsonata(
      expr: "$average(undefined)"
    )

    expect(jsonata.call(input)).to eq(nil)
  end
end