require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Comparison Operators" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "3>-3"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "3>3"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "3=3"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "\"3\"=\"3\""
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "\"3\"=3"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "\"hello\" = \"hello\""
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "\"hello\" != \"world\""
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "\"hello\" < \"world\""
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case008" do
    jsonata, input = build_jsonata(
      expr: "\"32\" < 42"
    )

    expect { jsonata.call(input) }.to raise_error("T2009")
  end

  xit "case009" do
    # This is a problem because null and undefined are different in JS
    jsonata, input = build_jsonata(
      expr: "null <= \"world\""
    )

    expect { jsonata.call(input) }.to raise_error("T2010")
  end

  it "case010" do
    jsonata, input = build_jsonata(
      expr: "3 >= true"
    )

    expect { jsonata.call(input) }.to raise_error("T2010")
  end

  it "case011" do
    jsonata, input = build_jsonata(
      expr: "foo.bar > bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case012" do
    jsonata, input = build_jsonata(
      expr: "foo.bar >= bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case013" do
    jsonata, input = build_jsonata(
      expr: "foo.bar<bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case014" do
    jsonata, input = build_jsonata(
      expr: "foo.bar<=bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case015" do
    jsonata, input = build_jsonata(
      expr: "bar>foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case016" do
    jsonata, input = build_jsonata(
      expr: "bar < foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case017" do
    jsonata, input = build_jsonata(
      expr: "foo.bar = bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  it "case018" do
    jsonata, input = build_jsonata(
      expr: "foo.bar != bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case019" do
    jsonata, input = build_jsonata(
      expr: "bar = foo.bar + 56",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(true)
  end

  it "case020" do
    jsonata, input = build_jsonata(
      expr: "bar !=foo.bar + 56",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(false)
  end

  xit "case021" do
    jsonata, input = build_jsonata(
      expr: "foo.blah.baz[fud = \"hello\"]",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq({
      "fud" => "hello"
    })
  end

  xit "case022" do
    jsonata, input = build_jsonata(
      expr: "foo.blah.baz[fud != \"world\"]",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq({
      "fud" => "hello"
    })
  end

  xit "case023" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.Product[Price > 30].Price",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      34.45,
      34.45,
      107.99
    ])
  end

  xit "case024" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.Product.Price[$<=35]",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq([
      34.45,
      21.67,
      34.45
    ])
  end

  it "case025" do
    jsonata, input = build_jsonata(
      expr: "false > 1"
    )

    expect { jsonata.call(input) }.to raise_error("T2010")
  end

  xit "case026" do
    jsonata, input = build_jsonata(
      expr: "false > $x"
    )

    expect { jsonata.call(input) }.to raise_error("T2010")
  end

  xit "case027" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr:  "3 > $x",
    )

    expect(jsonata.call(input)).to eq(nil)
  end

  xit "case028" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr:  "$x <= \"hello\"",
    )

    expect(jsonata.call(input)).to eq(nil)
  end
end
