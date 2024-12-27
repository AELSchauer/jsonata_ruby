require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Variables" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "$price.foo.bar"
    )
    bindings = {
      "price" => {
          "foo" => {
              "bar" => 45
          }
      }
    }

    expect(jsonata.call(input, bindings)).to eq(45)
  end

  it "case001" do
    # Repeat case000
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "$var[1]",
      dataset: "dataset5"
    )

    bindings = {
      "var" => [
        1,
        2,
        3
      ]
    }

    expect(jsonata.call(input, bindings)).to eq(2)
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "$.foo.bar",
      dataset: "dataset0"
    )

    bindings = {
      "price" => {
        "foo" => {
          "bar" => 45
        }
      }
    }

    expect(jsonata.call(input, bindings)).to eq(42)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "$a := 5"
    )

    expect(jsonata.call(input)).to eq(5)
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "$a := $b := 5"
    )

    expect(jsonata.call(input)).to eq(5)
  end

  xit "case006" do
    jsonata, input = build_jsonata(
      expr: "($a := $b := 5; $a)"
    )

    expect(jsonata.call(input)).to eq(5)
  end

  xit "case007" do
    jsonata, input = build_jsonata(
      expr: "($a := $b := 5; $b)"
    )

    expect(jsonata.call(input)).to eq(5)
  end

  xit "case008" do
    jsonata, input = build_jsonata(
      expr: "( $a := 5; $a := $a + 2; $a )"
    )

    expect(jsonata.call(input)).to eq(7)
  end

  it "case009" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "[1,2,3].$v"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  xit "case010" do
    jsonata, input = build_jsonata(
      expr: "( $foo := \"defined\"; ( $foo := nothing ); $foo )"
    )

    expect(jsonata.call(input)).to eq("defined")
  end

  xit "case011" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "( $foo := \"defined\"; ( $foo := nothing; $foo ) )"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  xit "case011" do
    jsonata, input = build_jsonata(
      expr: "($a := [1,2]; $a[1]:=3; $a)"
    )

    expect { jsonata.call(input) }.to raise_error("S0212")
  end
end
