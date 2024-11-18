require "./lib/jsonata"
require "json"

describe "Fields are translated" do
  # These are test cases copied over from the source JS repo
  describe "field datasets" do
    it "case000" do
      jsonata = build_jsonata(
        expr: "foo.bar",
        dataset: "dataset0"
      )

      expect(jsonata.call).to eq(42)
    end

    it "case001" do
      jsonata = build_jsonata(
        expr: "foo.blah",
        dataset: "dataset0"
      )

      expect(jsonata.call).to eq([
        {
            "baz" => {
                "fud" => "hello"
            }
        },
        {
            "baz" => {
                "fud" => "world"
            }
        },
        {
            "bazz" => "gotcha"
        }
      ])
    end

    it "case002" do
      jsonata = build_jsonata(
        expr: "foo.blah.bazz",
        dataset: "dataset0"
      )

      expect(jsonata.call).to eq("gotcha")
    end

    it "case003" do
      jsonata = build_jsonata(
        expr: "foo.blah.baz",
        dataset: "dataset0"
      )

      expect(jsonata.call).to eq([
        {
            "fud" => "hello"
        },
        {
            "fud" => "world"
        }
      ])
    end

    it "case004" do
      jsonata = build_jsonata(
        expr: "foo.blah.baz.fud",
        dataset: "dataset0"
      )

      expect(jsonata.call).to eq([
        "hello",
        "world"
      ])
    end

    it "case005" do
      jsonata = build_jsonata(
        expr: "Other.Misc",
        dataset: "dataset1"
      )

      expect(jsonata.call).to eq(nil)
    end

    it "case006" do
      jsonata = build_jsonata(
        expr: "bazz",
        dataset: "dataset2"
      )

      expect(jsonata.call).to eq("gotcha")
    end

    it "case007" do
      jsonata = build_jsonata(
        expr: "fud",
        dataset: "dataset3"
      )

      expect(jsonata.call).to eq([
        "hello",
        "world"
      ])
    end
  end

  # Helper setup functions
  def build_jsonata(expr:, dataset:)
    Jsonata.new(expr, JSON.parse(File.read("./spec/fixtures/#{dataset}.json")))
  end
end