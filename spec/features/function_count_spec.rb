require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Function -- Count" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "$count(Account.Order.Product.(Price * Quantity))",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq(4)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.$count(Product.(Price * Quantity))",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([2,2])
  end

  xit "case002" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.(OrderID & \": \" & $count(Product.(Price*Quantity)))",
    )

    expect(jsonata.call(input)).to eq([
      "order103: 2",
      "order104: 2"
    ])
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "$count([])",
    )

    expect(jsonata.call(input)).to eq(0)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "$count([1,2,3])"
    )

    expect(jsonata.call(input)).to eq(3)
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "$count([\"1\",\"2\",\"3\"])"
    )

    expect(jsonata.call(input)).to eq(3)
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "$count([\"1\",\"2\",3])"
    )

    expect(jsonata.call(input)).to eq(3)
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "$count(1)"
    )

    expect(jsonata.call(input)).to eq(1)
  end

  xit "case008" do
    jsonata, input = build_jsonata(
      expr: "$count([],[])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case009" do
    jsonata, input = build_jsonata(
      expr: "$count([1,2,3],[])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case010" do
    jsonata, input = build_jsonata(
      expr: "$count([],[],[])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case010" do
    jsonata, input = build_jsonata(
      expr: "$count([1,2],[],[])"
    )

    expect { jsonata.call(input) }.to raise_error("T0410")
  end

  xit "case011" do
    # undefined
    jsonata, input = build_jsonata(
      expr: "$count(undefined)"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  it "case012" do
    jsonata, input = build_jsonata(
      expr: "$count([1,2,3,4]) / 2"
    )

    expect(jsonata.call(input)).to eq(2)
  end
end