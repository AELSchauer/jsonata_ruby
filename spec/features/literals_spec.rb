require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Literals" do
  it "case000" do
    # Undefined result
    jsonata, input = build_jsonata(
      expr: "\"hello\""
    )

    expect(jsonata.call(input)).to eq("hello")
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "'hello'"
    )

    expect(jsonata.call(input)).to eq("hello")
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "\"Wayne's World\""
    )

    expect(jsonata.call(input)).to eq("Wayne's World")
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "42"
    )

    expect(jsonata.call(input)).to eq(42)
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "-42"
    )

    expect(jsonata.call(input)).to eq(-42)
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "3.14159"
    )

    expect(jsonata.call(input)).to eq(3.14159)
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "6.022e23"
    )

    expect(jsonata.call(input)).to eq(6.022e+23)
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "1.602E-19"
    )

    expect(jsonata.call(input)).to eq(1.602e-19)
  end

  xit "case008" do
    jsonata, input = build_jsonata(
      expr: "10e1000"
    )

    expect { jsonata.call(input) }.to raise_error("S0102")
  end

  it "case009" do
    jsonata, input = build_jsonata(
      expr: "\"hello\\tworld\""
    )

    expect(jsonata.call(input)).to eq("hello\tworld")
  end

  it "case010" do
    jsonata, input = build_jsonata(
      expr: "\"hello\\nworld\""
    )

    expect(jsonata.call(input)).to eq("hello\nworld")
  end

  it "case011" do
    jsonata, input = build_jsonata(
      expr: "\"hello \\\"world\\\"\""
    )

    expect(jsonata.call(input)).to eq("hello \"world\"")
  end

  it "case012" do
    jsonata, input = build_jsonata(
      expr: "\"C:\\\\Test\\\\test.txt\""
    )

    expect(jsonata.call(input)).to eq("C:\\Test\\test.txt")
  end

  xit "case013" do
    jsonata, input = build_jsonata(
      expr: "\"\\u03BB-calculus rocks\""
    )

    expect(jsonata.call(input)).to eq("λ-calculus rocks")
  end

  it "case014" do
    jsonata, input = build_jsonata(
      expr: "\"𝄞\""
    )

    expect(jsonata.call(input)).to eq("𝄞")
  end

  xit "case015" do
    jsonata, input = build_jsonata(
      expr: "\"\\y\""
    )

    expect { jsonata.call(input) }.to raise_error("S0103")
  end

  xit "case016" do
    jsonata, input = build_jsonata(
      expr: "\"\\u\""
    )

    expect { jsonata.call(input) }.to raise_error("S0104")
  end

  xit "case017" do
    jsonata, input = build_jsonata(
      expr: "\"\\u123t\""
    )

    expect { jsonata.call(input) }.to raise_error("S0104")
  end

  xit "case018" do
    jsonata, input = build_jsonata(
      expr: "{ 'foo': { 'sequence': 123, 'bar': 'baz' } } "
    )

    expect(jsonata.call(input)).to eq({
      "foo" => {
        "sequence" => 123,
        "bar" => "baz"
      }
    })
  end

  xit "case019" do
    jsonata, input = build_jsonata(
      expr: "{ 'foo': { 'sequence': true, 'bar': 'baz' } } "
    )

    expect(jsonata.call(input)).to eq({
      "foo" => {
        "sequence" => true,
        "bar" => "baz"
      }
    })
  end
end
