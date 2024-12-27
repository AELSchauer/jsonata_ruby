require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Range Operator" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "[0..9]"
    )

    expect(jsonata.call(input)).to eq([
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9
    ])
  end

  it "case001" do
    jsonata, input = build_jsonata(
      expr: "[0..9][$ % 2 = 0]"
    )

    expect(jsonata.call(input)).to eq([
      0,
      2,
      4,
      6,
      8
    ])
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "[0, 4..9, 20, 22]"
    )

    expect(jsonata.call(input)).to eq([
      0,
      4,
      5,
      6,
      7,
      8,
      9,
      20,
      22
    ])
  end

  it "case003" do
    jsonata, input = build_jsonata(
      expr: "[5..2]"
    )

    expect(jsonata.call(input)).to eq([])
  end

  it "case004" do
    jsonata, input = build_jsonata(
      expr: "[5..2, 2..5]"
    )

    expect(jsonata.call(input)).to eq([
      2,
      3,
      4,
      5
    ])
  end

  it "case005" do
    jsonata, input = build_jsonata(
      expr: "[-2..2]"
    )

    expect(jsonata.call(input)).to eq([
      -2,
      -1,
      0,
      1,
      2
    ])
  end

  it "case006" do
    jsonata, input = build_jsonata(
      expr: "[-2..2].($*$)"
    )

    expect(jsonata.call(input)).to eq([
      4,
      1,
      0,
      1,
      4
    ])
  end

  it "case007" do
    jsonata, input = build_jsonata(
      expr: "[-2..blah]"
    )

    expect(jsonata.call(input)).to eq([])
  end

  it "case008" do
    jsonata, input = build_jsonata(
      expr: "[blah..5, 3, -2..blah]"
    )

    expect(jsonata.call(input)).to eq([3])
  end

  it "case009" do
    jsonata, input = build_jsonata(
      expr: "[1.1 .. 5]"
    )

    expect { jsonata.call(input) }.to raise_error("T2003")
  end

  it "case010" do
    jsonata, input = build_jsonata(
      expr: "[1 .. 5.5]"
    )

    expect { jsonata.call(input) }.to raise_error("T2004")
  end

  it "case011" do
    jsonata, input = build_jsonata(
      expr: "[10..1.5]"
    )

    expect { jsonata.call(input) }.to raise_error("T2004")
  end

  it "case012" do
    jsonata, input = build_jsonata(
      expr: "[true..false]"
    )

    expect { jsonata.call(input) }.to raise_error("T2003")
  end

  it "case013" do
    jsonata, input = build_jsonata(
      expr: "['dogs'..'cats']"
    )

    expect { jsonata.call(input) }.to raise_error("T2003")
  end

  it "case014" do
    jsonata, input = build_jsonata(
      expr: "[1..'']"
    )

    expect { jsonata.call(input) }.to raise_error("T2004")
  end

  it "case015" do
    jsonata, input = build_jsonata(
      expr: "[1..[]]"
    )

    expect { jsonata.call(input) }.to raise_error("T2004")
  end

  it "case016" do
    jsonata, input = build_jsonata(
      expr: "[1..{}]"
    )

    expect { jsonata.call(input) }.to raise_error("T2004")
  end

  it "case017" do
    jsonata, input = build_jsonata(
      expr: "[1..false]"
    )

    expect { jsonata.call(input) }.to raise_error("T2004")
  end

  it "case018" do
    jsonata, input = build_jsonata(
      expr: "[2..true]"
    )

    expect { jsonata.call(input) }.to raise_error("T2004")
  end

  xit "case019" do
    # This is a problem because null and undefined are different in JS
    jsonata, input = build_jsonata(
      expr: "[$x..true]"
    )

    expect { jsonata.call(input) }.to raise_error("T2004")
  end

  xit "case020" do
    # This is a problem because null and undefined are different in JS
    jsonata, input = build_jsonata(
      expr: "[false..$x]"
    )

    expect { jsonata.call(input) }.to raise_error("T2003")
  end

  xit "case021" do
    # {
    #   "expr": "[1..10000000] ~> $count()",
    #   "dataset": null,
    #   "bindings": {},
    #   "result": 1e7,
    #   "timelimit": 10000,
    #   "depth": 10
    # }
  end

  xit "case022" do
    jsonata, input = build_jsonata(
      expr: "[0..10000000] ~> $count()"
    )

    expect { jsonata.call(input) }.to raise_error("D2014")
  end

  xit "case023" do
    jsonata, input = build_jsonata(
      expr: "[1..10000001] ~> $count()",
    )

    expect { jsonata.call(input) }.to raise_error("D2014")
  end

  xit "case024" do
    # {
    #   "expr": "[100..10000099] ~> $count()",
    #   "dataset": null,
    #   "bindings": {},
    #   "result": 1e7,
    #   "timelimit": 10000,
    #   "depth": 10
    # }
  end
end
