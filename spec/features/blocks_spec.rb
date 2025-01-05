require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Blocks" do
  it "case000" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "()"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "(1; 2; 3)"
    )

    expect(jsonata.call(input)).to eq(3)
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "(1; 2; 3;)"
    )

    expect(jsonata.call(input)).to eq(3)
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "($a:=1; $b:=2; $c:=($a:=4; $a+$b); $a+$c)"
    )

    expect(jsonata.call(input)).to eq(7)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.Product.($var1 := Price ; $var2:=Quantity; $var1 * $var2)",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      68.9,
      21.67,
      137.8,
      107.99
    ])
  end

  xit "case005" do
    jsonata, input = build_jsonata(
      expr: "(  $func := function($arg) {$arg.Account.Order[0].OrderID};  $func($))",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq("order103")
  end

  xit "case006" do
    jsonata, input = build_jsonata(
      expr: "(  $func := function($arg) {$arg.Account.Order[0]};  $func($).OrderID)",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq("order103")
  end
end
