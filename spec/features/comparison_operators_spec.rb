require "./lib/jsonata"
require "./spec/features/spec_helper"
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
    jsonata = build_jsonata(
      expr: "3=3"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case003" do
    jsonata = build_jsonata(
      expr: "\"3\"=\"3\""
    )

    expect(jsonata.call).to eq(true)
  end

  it "case004" do
    jsonata = build_jsonata(
      expr: "\"3\"=3"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case005" do
    jsonata = build_jsonata(
      expr: "\"hello\" = \"hello\""
    )

    expect(jsonata.call).to eq(true)
  end

  it "case006" do
    jsonata = build_jsonata(
      expr: "\"hello\" != \"world\""
    )

    expect(jsonata.call).to eq(true)
  end

  it "case007" do
    jsonata = build_jsonata(
      expr: "\"hello\" < \"world\""
    )

    expect(jsonata.call).to eq(true)
  end

  it "case008" do
    jsonata = build_jsonata(
      expr: "\"32\" < 42"
    )

    expect { jsonata.call }.to raise_error("T2009")
  end

  xit "case009" do
    # This is a problem because null and undefined are different in JS
    jsonata = build_jsonata(
      expr: "null <= \"world\""
    )

    expect { jsonata.call }.to raise_error("T2010")
  end

  it "case010" do
    jsonata = build_jsonata(
      expr: "3 >= true"
    )

    expect { jsonata.call }.to raise_error("T2010")
  end

  it "case011" do
    jsonata = build_jsonata(
      expr: "foo.bar > bar",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case012" do
    jsonata = build_jsonata(
      expr: "foo.bar >= bar",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case013" do
    jsonata = build_jsonata(
      expr: "foo.bar<bar",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case014" do
    jsonata = build_jsonata(
      expr: "foo.bar<=bar",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case015" do
    jsonata = build_jsonata(
      expr: "bar>foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case016" do
    jsonata = build_jsonata(
      expr: "bar < foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case017" do
    jsonata = build_jsonata(
      expr: "foo.bar = bar",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  it "case018" do
    jsonata = build_jsonata(
      expr: "foo.bar != bar",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case019" do
    jsonata = build_jsonata(
      expr: "bar = foo.bar + 56",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(true)
  end

  it "case020" do
    jsonata = build_jsonata(
      expr: "bar !=foo.bar + 56",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq(false)
  end

  xit "case021" do
    jsonata = build_jsonata(
      expr: "foo.blah.baz[fud = \"hello\"]",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq({
      "fud" => "hello"
    })
  end

  xit "case022" do
    jsonata = build_jsonata(
      expr: "foo.blah.baz[fud != \"world\"]",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq({
      "fud" => "hello"
    })
  end

  xit "case023" do
    jsonata = build_jsonata(
      expr: "Account.Order.Product[Price > 30].Price",
      dataset: "dataset5"
    )

    expect(jsonata.call).to eq([
      34.45,
      34.45,
      107.99
    ])
  end

  xit "case024" do
    jsonata = build_jsonata(
      expr: "Account.Order.Product.Price[$<=35]",
      dataset: "dataset0"
    )

    expect(jsonata.call).to eq([
      34.45,
      21.67,
      34.45
    ])
  end

  it "case025" do
    jsonata = build_jsonata(
      expr: "false > 1"
    )

    expect { jsonata.call }.to raise_error("T2010")
  end

  xit "case026" do
    jsonata = build_jsonata(
      expr: "false > $x"
    )

    expect { jsonata.call }.to raise_error("T2010")
  end

  xit "case027" do
    # Undefined result
    jsonata = build_jsonata(
      expr:  "3 > $x",
    )

    expect(jsonata.call).to eq()
  end

  xit "case028" do
    # Undefined result
    jsonata = build_jsonata(
      expr:  "$x <= \"hello\"",
    )

    expect(jsonata.call).to eq()
  end
end
