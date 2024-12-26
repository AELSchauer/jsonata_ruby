require "./lib/jsonata"
require "./spec/features/spec_helper"
require "json"

# These are test cases copied over from the source JS repo
describe "Flattening" do
  it "case000" do
    jsonata, input = build_jsonata(
      expr: "Account.Order.[Product.Price]",
      dataset: "dataset5"
    )

    expect(jsonata.call(input)).to eq([
      [
          34.45,
          21.67
      ],
      [
          34.45,
          107.99
      ]
    ])
  end

  xit "case001" do
    jsonata, input = build_jsonata(
      expr: "$.nest0",
      data: [
        {
            "nest0": [
                1,
                2
            ]
        },
        {
            "nest0": [
                3,
                4
            ]
        }
    ]
    )

    expect(jsonata.call(input)).to eq([1, 2, 3, 4])
  end

  it "case002" do
    jsonata, input = build_jsonata(
      expr: "nest0",
      data: [
        {
            "nest0" => [
                1,
                2
            ]
        },
        {
            "nest0" => [
                3,
                4
            ]
        }
      ]
    )

    expect(jsonata.call(input)).to eq([1, 2, 3, 4])
  end

  xit "case003" do
    jsonata, input = build_jsonata(
      expr: "$[0]",
      data: [
        {
            "nest0": [
                1,
                2
            ]
        },
        {
            "nest0": [
                3,
                4
            ]
        }
      ]
    )

    expect(jsonata.call(input)).to eq({
      "nest0" => [
          1,
          2
      ]
    })
  end

  xit "case004" do
    jsonata, input = build_jsonata(
      expr: "$[1]",
      data: [
        {
          "nest0": [
            1,
            2
          ]
        },
        {
          "nest0": [
            3,
            4
          ]
        }
      ]
    )

    expect(jsonata.call(input)).to eq({
      "nest0" => [3,4]
    })
  end

  xit "case005" do
    jsonata, input = build_jsonata(
      expr: "$[-1]",
      data: [
        {
          "nest0": [1,2]
        },
        {
          "nest0": [3,4]
        }
      ]
    )

    expect(jsonata.call(input)).to eq({
      "nest0" => [3,4]
    })
  end

  xit "case006" do
    jsonata, input = build_jsonata(
      expr: "$[0].nest0",
      data: [
        {
          "nest0": [1,2]
        },
        {
          "nest0": [3,4]
        }
      ]
    )

    expect(jsonata.call(input)).to eq([1,2])
  end

  xit "case007" do
    jsonata, input = build_jsonata(
      expr: "$[1].nest0",
      data: [
        {
          "nest0": [ 1, 2 ]
        },
        {
          "nest0": [3,4]
        }
      ]
    )

    expect(jsonata.call(input)).to eq([3,4])
  end

  xit "case008" do
    jsonata, input = build_jsonata(
      expr: "$[0].nest0[0]",
      data: [
        {
          "nest0": [1,2]
        },
        {
          "nest0": [3,4]
        }
      ]
    )

    expect(jsonata.call(input)).to eq(1)
  end

  it "case009" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.[nest2.[nest3]]]",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([
      [
        [[1],[2]],
        [[3],[4]],
      ],
      [
        [[5],[6]],
        [[7],[8]],
      ]
    ])
  end

  it "case010" do
    jsonata, input = build_jsonata(
      expr: "nest0.nest1.[nest2.[nest3]]",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([
      [[1],[2]],
      [[3],[4]],
      [[5],[6]],
      [[7],[8]]
    ])
  end

  it "case011" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.nest2.[nest3]]",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([
      [[1],[2],[3],[4]],
      [[5],[6],[7],[8]]
    ])
  end

  it "case012" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.[nest2.nest3]]",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([
      [[1,2],[3,4]],
      [[5,6],[7,8]]
    ])
  end

  it "case013" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.nest2.nest3]",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([
      [1,2,3,4],
      [5,6,7,8]
    ])
  end

  it "case014" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.nest2.nest3]",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([
      [1,2,3,4],
      [5,6,7,8]
    ])
  end

  it "case014" do
    jsonata, input = build_jsonata(
      expr: "nest0.nest1.[nest2.nest3]",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([
      [1,2],
      [3,4],
      [5,6],
      [7,8]
    ])
  end

  it "case015" do
    jsonata, input = build_jsonata(
      expr: "nest0.nest1.nest2.[nest3]",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([
      [1],[2],[3],[4],[5],[6],[7],[8]
    ])
  end

  it "case016" do
    jsonata, input = build_jsonata(
      expr: "nest0.nest1.nest2.nest3",
      dataset: "dataset8"
    )

    expect(jsonata.call(input)).to eq([1,2,3,4,5,6,7,8])
  end

  it "case017" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.[nest2.[nest3]]]",
      dataset: "dataset24"
    )

    expect(jsonata.call(input)).to eq([
      [
        [[1],[2]],
        [[3],[4]]
      ],
      [
        [[5],[6]],
        [[7],[8]]
      ]
    ])
  end

  it "case018" do
    jsonata, input = build_jsonata(
      expr: "nest0.nest1.[nest2.[nest3]]",
      dataset: "dataset24"
    )

    expect(jsonata.call(input)).to eq([
      [[1],[2]],
      [[3],[4]],
      [[5],[6]],
      [[7],[8]]
    ])
  end

  it "case019" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.nest2.[nest3]]",
      dataset: "dataset24"
    )

    expect(jsonata.call(input)).to eq([
      [[1],[2],[3],[4]],
      [[5],[6],[7],[8]]
    ])
  end

  it "case020" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.[nest2.nest3]]",
      dataset: "dataset24"
    )

    expect(jsonata.call(input)).to eq([
      [[1,2],[3,4]],
      [[5,6],[7,8]]
    ])
  end

  it "case021" do
    jsonata, input = build_jsonata(
      expr: "nest0.[nest1.nest2.nest3]",
      dataset: "dataset24"
    )

    expect(jsonata.call(input)).to eq([
      [1,2,3,4],
      [5,6,7,8]
    ])
  end

  it "case022" do
    jsonata, input = build_jsonata(
      expr: "nest0.nest1.[nest2.nest3]",
      dataset: "dataset24"
    )

    expect(jsonata.call(input)).to eq([
      [1,2],
      [3,4],
      [5,6],
      [7,8]
    ])
  end

  it "case023" do
    jsonata, input = build_jsonata(
      expr: "nest0.nest1.nest2.[nest3]",
      dataset: "dataset24"
    )

    expect(jsonata.call(input)).to eq([
      [1],[2],[3],[4],[5],[6],[7],[8]
    ])
  end

  it "case024" do
    jsonata, input = build_jsonata(
      expr: "nest0.nest1.nest2.nest3",
      dataset: "dataset24"
    )

    expect(jsonata.call(input)).to eq([1,2,3,4,5,6,7,8])
  end

  it "case025" do
    jsonata, input = build_jsonata(
      expr: "{\"a\": 1 }.a"
    )

    expect(jsonata.call(input)).to eq(1)
  end

  it "case026" do
    jsonata, input = build_jsonata(
      expr: "a",
      data: {
        "a" => 1
      }
    )

    expect(jsonata.call(input)).to eq(1)
  end

  it "case027" do
    jsonata, input = build_jsonata(
      expr: "{\"a\": [1] }.a"
    )

    expect(jsonata.call(input)).to eq([1])
  end

  it "case028" do
    jsonata, input = build_jsonata(
      expr: "a",
      data: {
        "a" => [1]
      }
    )

    expect(jsonata.call(input)).to eq([1])
  end

  it "case029" do
    jsonata, input = build_jsonata(
      expr: "{\"a\": [[1]] }.a",
    )

    expect(jsonata.call(input)).to eq([[1]])
  end

  it "case030" do
    jsonata, input = build_jsonata(
      expr: "a",
      data: {
        "a" => [[1]]
      }
    )

    expect(jsonata.call(input)).to eq([[1]])
  end

  it "case031" do
    jsonata, input = build_jsonata(
      expr: "[{\"a\":[1,2]}, {\"a\":[3]}].a"
    )

    expect(jsonata.call(input)).to eq([1,2,3])
  end

  it "case032" do
    jsonata, input = build_jsonata(
      expr: "a",
      data: [
        {
          "a" => [1,2]
        },
        {
          "a" => [3]
        }
      ]
    )

    expect(jsonata.call(input)).to eq([1,2,3])
  end

  it "case033" do
    jsonata, input = build_jsonata(
      expr: "[{\"a\":[{\"b\":[1]}, {\"b\":[2]}]}, {\"a\":[{\"b\":[3]}, {\"b\":[4]}]}].a[0].b"
    )

    expect(jsonata.call(input)).to eq([1,3])
  end

  it "case034" do
    jsonata, input = build_jsonata(
      expr: "a[0].b",
      data: [
        {
          "a" => [
            {"b" => [1]},
            {"b" => [2]}
          ]
        },
        {
          "a" => [
            {"b" => [3]},
            {"b" => [4]}
          ]
        }
      ]
    )

    expect(jsonata.call(input)).to eq([1])
  end

  xit "case034a" do
    jsonata, input = build_jsonata(
      expr: "$.a[0].b",
      data: [
        {
          "a" => [
            {"b" => [1]},
            {"b" => [2]}
          ]
        },
        {
          "a" => [
            {"b" => [3]},
            {"b" => [4]}
          ]
        }
      ]
    )

    expect(jsonata.call(input)).to eq([1])
  end

  it "case035" do
    jsonata, input = build_jsonata(
      expr: "a.b[0]",
      data: [
        {
          "a" => [
            {"b" => [1]},
            {"b" => [2]}
          ]
        },
        {
          "a" => [
            {"b" => [3]},
            {"b" => [4]}
          ]
        }
      ]
    )

    expect(jsonata.call(input)).to eq([1,2,3,4])
  end

  it "case036" do
    jsonata, input = build_jsonata(
      expr: "Phone[type=\"mobile\"].number",
      dataset: "dataset1",
    )

    expect(jsonata.call(input)).to eq("077 7700 1234")
  end

  it "case037" do
    jsonata, input = build_jsonata(
      expr: "Phone[type=\"mobile\"][].number",
      dataset: "dataset1",
    )

    expect(jsonata.call(input)).to eq(["077 7700 1234"])
  end

  it "case038" do
    jsonata, input = build_jsonata(
      expr: "Phone[][type=\"mobile\"].number",
      dataset: "dataset1",
    )

    expect(jsonata.call(input)).to eq(["077 7700 1234"])
  end

  it "case039" do
    jsonata, input = build_jsonata(
      expr: "Phone[type=\"office\"][].number",
      dataset: "dataset1",
    )

    expect(jsonata.call(input)).to eq([
      "01962 001234",
      "01962 001235"
    ])
  end

  it "case040" do
    jsonata, input = build_jsonata(
      expr: "Phone{type: number}",
      dataset: "dataset1",
    )

    expect(jsonata.call(input)).to eq({
      "home" => "0203 544 1234",
      "office" => [
          "01962 001234",
          "01962 001235"
      ],
      "mobile" => "077 7700 1234"
    })
  end

  it "case041" do
    jsonata, input = build_jsonata(
      expr: "Phone{type: number[]}",
      dataset: "dataset1",
    )

    expect(jsonata.call(input)).to eq({
      "home" => [
          "0203 544 1234"
      ],
      "office" => [
          "01962 001234",
          "01962 001235"
      ],
      "mobile" => [
          "077 7700 1234"
      ]
    })
  end

  xit "case042" do
    jsonata, input = build_jsonata(
      expr: "$[type='command'][]",
      data: [{"type":"command"},{"type":"commands"}]
    )

    expect(jsonata.call(input)).to eq([{"type":"command"}])
  end

  xit "case043" do
    jsonata, input = build_jsonata(
      expr: "$[][type='command']",
      data: [{"type":"command"},{"type":"commands"}]
    )

    expect(jsonata.call(input)).to eq([{"type":"command"}])
  end

  xit "case044" do
    jsonata, input = build_jsonata(
      expr: "$filter($, function($e) { $e != 0 })[]",
      data: [0,0,5,0]
    )

    expect(jsonata.call(input)).to eq([5])
  end

  xit "case045" do
    jsonata, input = build_jsonata(
      expr: "$.tags[title='example'][]",
      data: {
        "tags": [
          {
            "title": "example",
            "description": "Hello"
          }
        ]
      }
    )

    expect(jsonata.call(input)).to eq([5])
  end
end
