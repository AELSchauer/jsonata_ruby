require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Numeric Operators" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "foo.bar + bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(140)
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "bar + foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(140)
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "foo.bar - bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(-56)
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "bar - foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(56)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "foo.bar * bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(4116)
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "bar * foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(4116)
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "foo.bar / bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(0.42857142857142855)
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "bar / foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(2.3333333333333335)
  end

  it "case008" do
    jsonata, input = build_jsonata(
      expr: "foo.bar % bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(42)
  end

  it "case009" do
    jsonata, input = build_jsonata(
      expr: "bar % foo.bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(14)
  end

  it "case010" do
    jsonata, input = build_jsonata(
      expr: "bar + foo.bar * bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(4214)
  end

  it "case011" do
    jsonata, input = build_jsonata(
      expr: "foo.bar * bar + bar",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(4214)
  end

  xit "case012" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "24 * notexist",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(4214)
  end

  xit "case013" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "notexist + 1",
      dataset: "dataset0"
    )

    expect(jsonata.call(input)).to eq(nil)
  end
  
  xit "case014" do
    jsonata, input = build_jsonata(
      expr: "1/(10e300 * 10e100) "
    )
    
    expect { jsonata.call(input) }.to raise_error("D1001")
  end

  it "case015" do
    jsonata, input = build_jsonata(
      expr: "\"5\" + \"5\""
    )

    expect { jsonata.call(input) }.to raise_error("T2001")
  end

  xit "case016" do
    jsonata, input = build_jsonata(
      expr: "- notexist",
      dataset: "dataset0"
    )

    expect { jsonata.call(input) }.to raise_error("T2001")
  end

  it "case017" do
    jsonata, input = build_jsonata(
      expr: "false + 1",
      dataset: "dataset0"
    )

    expect { jsonata.call(input) }.to raise_error("T2001")
  end

  xit "case018" do
    jsonata, input = build_jsonata(
      expr: "false + $x",
      dataset: "dataset0"
    )

    expect { jsonata.call(input) }.to raise_error("T2001")
  end
end
