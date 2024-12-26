require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Boolean Expressions" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "true"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "false"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "false or false"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "false or true"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "true or false"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "true or true"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "false and false"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "false and true"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case008" do
    jsonata, input = build_jsonata(
      expr: "true and false"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case009" do
    jsonata, input = build_jsonata(
      expr: "true and true"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  xit "case010" do
    jsonata, input = build_jsonata(
      expr: "$not(false)",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  xit "case011" do
    jsonata, input = build_jsonata(
      expr: "$not(true)",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case012" do
    jsonata, input = build_jsonata(
      expr: "and=1 and or=2",
      data: {"and" => 1, "or" => 2}
    )

    expect(jsonata.call(input)).to eq(true)
  end

  xit "case013" do
    jsonata, input = build_jsonata(
      expr: "and>1 or or!=2",
      data: {"and" => 1, "or" => 2}
    )

    expect(jsonata.call(input)).to eq(true)
  end

  xit "case014" do
    jsonata, input = build_jsonata(
      expr: "and>1 or or!=2",
      data: {"and" => 1, "or" => 2}
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case015" do
    jsonata, input = build_jsonata(
      expr: "and and and",
      data: {"and" => 1, "or" => 2}
    )

    expect(jsonata.call(input)).to eq(true)
  end

  xit "case016" do
    jsonata, input = build_jsonata(
      expr: "$[].content.origin.$lowercase(name)",
      dataset: "dataset11"
    )

    expect(jsonata.call(input)).to eq("fakeintegrationname")
  end

  it "case017" do
    jsonata, input = build_jsonata(
      expr: "true or foo",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case018" do
    jsonata, input = build_jsonata(
      expr: "foo or true",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case019" do
    jsonata, input = build_jsonata(
      expr: "false or foo",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case020" do
    jsonata, input = build_jsonata(
      expr: "foo or false",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case021" do
    jsonata, input = build_jsonata(
      expr: "foo or bar",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case022" do
    jsonata, input = build_jsonata(
      expr: "true and foo",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case023" do
    jsonata, input = build_jsonata(
      expr: "foo and true",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case024" do
    jsonata, input = build_jsonata(
      expr: "false and foo",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case025" do
    jsonata, input = build_jsonata(
      expr: "foo and false",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case026" do
    jsonata, input = build_jsonata(
      expr: "foo and bar",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  xit "case027" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "foo and bar",
      data: "null"
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  xit "case028" do
    # Will not evaluate rhs (which would error) because lhs is true
    jsonata, input = build_jsonata(
      expr: "foo = '' or $number(foo) = 0",
      data: {
        "foo" => ""
      }
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  xit "case029" do
    # Will not evaluate rhs (which would error) because lhs is false
    jsonata, input = build_jsonata(
      expr: "$type(data) = 'number' and data > 10",
      data: {
        "data" => "15"
      }
    )

    expect(jsonata.call(input)).to eq(false)
  end

  xit "case030" do
    # Throws error on right side of boolean expression (for CC of a catch)
    jsonata, input = build_jsonata(
      expr: "$type(data) = 'number' and data > 10",
      data: {
        "age" => "33 1/2"
      }
    )

    expect { jsonata.call(input) }.to raise_error("D3030")
  end
end
