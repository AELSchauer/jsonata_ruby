require "./lib/jsonata"
require "json"

# These are test cases copied over from the source JS repo
describe "Flattening" do
  it "case000" do
    jsonata = build_jsonata(
      expr: "Account.Order.[Product.Price]",
      dataset: "dataset5"
    )

    expect(jsonata.call).to eq([
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

  it "case001" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$.nest0",
    #   data: [
    #     {
    #         "nest0": [
    #             1,
    #             2
    #         ]
    #     },
    #     {
    #         "nest0": [
    #             3,
    #             4
    #         ]
    #     }
    # ]
    # )

    # expect(jsonata.call).to eq([1, 2, 3, 4])
  end

  it "case002" do
    jsonata = build_jsonata(
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

    expect(jsonata.call).to eq([1, 2, 3, 4])
  end

  it "case003" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$[0]",
    #   data: [
    #     {
    #         "nest0": [
    #             1,
    #             2
    #         ]
    #     },
    #     {
    #         "nest0": [
    #             3,
    #             4
    #         ]
    #     }
    #   ]
    # )

    # expect(jsonata.call).to eq({
    #   "nest0" => [
    #       1,
    #       2
    #   ]
    # })
  end

  it "case004" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$[1]",
    #   data: [
    #     {
    #         "nest0": [
    #             1,
    #             2
    #         ]
    #     },
    #     {
    #         "nest0": [
    #             3,
    #             4
    #         ]
    #     }
    #   ]
    # )

    # expect(jsonata.call).to eq({
    #   "nest0" => [
    #       3,
    #       4
    #   ]
    # })
  end

  it "case005" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$[-1]",
    #   data: [
    #     {
    #         "nest0": [
    #             1,
    #             2
    #         ]
    #     },
    #     {
    #         "nest0": [
    #             3,
    #             4
    #         ]
    #     }
    #   ]
    # )

    # expect(jsonata.call).to eq({
    #   "nest0" => [
    #       3,
    #       4
    #   ]
    # })
  end

  it "case006" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$[0].nest0",
    #   data: [
    #     {
    #         "nest0": [
    #             1,
    #             2
    #         ]
    #     },
    #     {
    #         "nest0": [
    #             3,
    #             4
    #         ]
    #     }
    #   ]
    # )

    # expect(jsonata.call).to eq([
    #     1,
    #     2
    # ])
  end

  it "case007" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$[1].nest0",
    #   data: [
    #     {
    #         "nest0": [
    #             1,
    #             2
    #         ]
    #     },
    #     {
    #         "nest0": [
    #             3,
    #             4
    #         ]
    #     }
    #   ]
    # )

    # expect(jsonata.call).to eq([
    #     3,
    #     4
    # ])
  end

  it "case008" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$[0].nest0[0]",
    #   data: [
    #     {
    #         "nest0": [
    #             1,
    #             2
    #         ]
    #     },
    #     {
    #         "nest0": [
    #             3,
    #             4
    #         ]
    #     }
    #   ]
    # )

    # expect(jsonata.call).to eq(1)
  end

  it "case009" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.[nest2.[nest3]]]",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([
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
    jsonata = build_jsonata(
      expr: "nest0.nest1.[nest2.[nest3]]",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([
      [[1],[2]],
      [[3],[4]],
      [[5],[6]],
      [[7],[8]]
    ])
  end

  it "case011" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.nest2.[nest3]]",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([
      [[1],[2],[3],[4]],
      [[5],[6],[7],[8]]
    ])
  end

  it "case012" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.[nest2.nest3]]",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([
      [[1,2],[3,4]],
      [[5,6],[7,8]]
    ])
  end

  it "case013" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.nest2.nest3]",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([
      [1,2,3,4],
      [5,6,7,8]
    ])
  end

  it "case014" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.nest2.nest3]",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([
      [1,2,3,4],
      [5,6,7,8]
    ])
  end

  it "case014" do
    jsonata = build_jsonata(
      expr: "nest0.nest1.[nest2.nest3]",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([
      [1,2],
      [3,4],
      [5,6],
      [7,8]
    ])
  end

  it "case015" do
    jsonata = build_jsonata(
      expr: "nest0.nest1.nest2.[nest3]",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([
      [1],[2],[3],[4],[5],[6],[7],[8]
    ])
  end

  it "case016" do
    jsonata = build_jsonata(
      expr: "nest0.nest1.nest2.nest3",
      dataset: "dataset8"
    )

    expect(jsonata.call).to eq([1,2,3,4,5,6,7,8])
  end

  it "case017" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.[nest2.[nest3]]]",
      dataset: "dataset24"
    )

    expect(jsonata.call).to eq([
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
    jsonata = build_jsonata(
      expr: "nest0.nest1.[nest2.[nest3]]",
      dataset: "dataset24"
    )

    expect(jsonata.call).to eq([
      [[1],[2]],
      [[3],[4]],
      [[5],[6]],
      [[7],[8]]
    ])
  end

  it "case019" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.nest2.[nest3]]",
      dataset: "dataset24"
    )

    expect(jsonata.call).to eq([
      [[1],[2],[3],[4]],
      [[5],[6],[7],[8]]
    ])
  end

  it "case020" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.[nest2.nest3]]",
      dataset: "dataset24"
    )

    expect(jsonata.call).to eq([
      [[1,2],[3,4]],
      [[5,6],[7,8]]
    ])
  end

  it "case021" do
    jsonata = build_jsonata(
      expr: "nest0.[nest1.nest2.nest3]",
      dataset: "dataset24"
    )

    expect(jsonata.call).to eq([
      [1,2,3,4],
      [5,6,7,8]
    ])
  end

  it "case022" do
    jsonata = build_jsonata(
      expr: "nest0.nest1.[nest2.nest3]",
      dataset: "dataset24"
    )

    expect(jsonata.call).to eq([
      [1,2],
      [3,4],
      [5,6],
      [7,8]
    ])
  end

  it "case023" do
    jsonata = build_jsonata(
      expr: "nest0.nest1.nest2.[nest3]",
      dataset: "dataset24"
    )

    expect(jsonata.call).to eq([
      [1],[2],[3],[4],[5],[6],[7],[8]
    ])
  end

  it "case024" do
    jsonata = build_jsonata(
      expr: "nest0.nest1.nest2.nest3",
      dataset: "dataset24"
    )

    expect(jsonata.call).to eq([1,2,3,4,5,6,7,8])
  end

  it "case025" do
    jsonata = build_jsonata(
      expr: "{\"a\": 1 }.a"
    )

    expect(jsonata.call).to eq(1)
  end

  it "case026" do
    jsonata = build_jsonata(
      expr: "a",
      data: {
        "a" => 1
      }
    )

    expect(jsonata.call).to eq(1)
  end

  it "case027" do
    jsonata = build_jsonata(
      expr: "{\"a\": [1] }.a"
    )

    expect(jsonata.call).to eq([1])
  end

  it "case028" do
    jsonata = build_jsonata(
      expr: "a",
      data: {
        "a" => [1]
      }
    )

    expect(jsonata.call).to eq([1])
  end

  it "case029" do
    jsonata = build_jsonata(
      expr: "{\"a\": [[1]] }.a",
    )

    expect(jsonata.call).to eq([[1]])
  end

  it "case030" do
    jsonata = build_jsonata(
      expr: "a",
      data: {
        "a" => [[1]]
      }
    )

    expect(jsonata.call).to eq([[1]])
  end

  it "case031" do
    jsonata = build_jsonata(
      expr: "[{\"a\":[1,2]}, {\"a\":[3]}].a"
    )

    expect(jsonata.call).to eq([1,2,3])
  end

  it "case032" do
    jsonata = build_jsonata(
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

    expect(jsonata.call).to eq([1,2,3])
  end

  it "case033" do
    jsonata = build_jsonata(
      expr: "[{\"a\":[{\"b\":[1]}, {\"b\":[2]}]}, {\"a\":[{\"b\":[3]}, {\"b\":[4]}]}].a[0].b"
    )

    expect(jsonata.call).to eq([1,3])
  end

  it "case034" do
    jsonata = build_jsonata(
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

    expect(jsonata.call).to eq([1])
  end

  it "case034a" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$.a[0].b",
    #   data: [
    #     {
    #       "a" => [
    #         {"b" => [1]},
    #         {"b" => [2]}
    #       ]
    #     },
    #     {
    #       "a" => [
    #         {"b" => [3]},
    #         {"b" => [4]}
    #       ]
    #     }
    #   ]
    # )

    # expect(jsonata.call).to eq([1])
  end

  it "case035" do
    jsonata = build_jsonata(
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

    expect(jsonata.call).to eq([1,2,3,4])
  end

  it "case036" do
    jsonata = build_jsonata(
      expr: "Phone[type=\"mobile\"].number",
      dataset: "dataset1",
    )

    expect(jsonata.call).to eq("077 7700 1234")
  end

  it "case037" do
    jsonata = build_jsonata(
      expr: "Phone[type=\"mobile\"][].number",
      dataset: "dataset1",
    )

    expect(jsonata.call).to eq(["077 7700 1234"])
  end

  it "case038" do
    jsonata = build_jsonata(
      expr: "Phone[][type=\"mobile\"].number",
      dataset: "dataset1",
    )

    expect(jsonata.call).to eq(["077 7700 1234"])
  end

  it "case039" do
    jsonata = build_jsonata(
      expr: "Phone[type=\"office\"][].number",
      dataset: "dataset1",
    )

    expect(jsonata.call).to eq([
      "01962 001234",
      "01962 001235"
    ])
  end

  it "case040" do
    jsonata = build_jsonata(
      expr: "Phone{type: number}",
      dataset: "dataset1",
    )

    expect(jsonata.call).to eq({
      "home" => "0203 544 1234",
      "office" => [
          "01962 001234",
          "01962 001235"
      ],
      "mobile" => "077 7700 1234"
    })
  end

  it "case041" do
    jsonata = build_jsonata(
      expr: "Phone{type: number[]}",
      dataset: "dataset1",
    )

    expect(jsonata.call).to eq({
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

  it "case042" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$[type='command'][]",
    #   data: [{"type":"command"},{"type":"commands"}]
    # )

    # expect(jsonata.call).to eq([{"type":"command"}])
  end

  it "case043" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$[][type='command']",
    #   data: [{"type":"command"},{"type":"commands"}]
    # )

    # expect(jsonata.call).to eq([{"type":"command"}])
  end

  it "case044" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$filter($, function($e) { $e != 0 })[]",
    #   data: [0,0,5,0]
    # )

    # expect(jsonata.call).to eq([5])
  end

  it "case045" do
    # TO-DO
    # jsonata = build_jsonata(
    #   expr: "$.tags[title='example'][]",
    #   data: {
    #     "tags": [
    #       {
    #         "title": "example",
    #         "description": "Hello"
    #       }
    #     ]
    #   }
    # )

    # expect(jsonata.call).to eq([5])
  end

  # Helper setup functions
  def build_jsonata(expr:, dataset: nil, data: "")
    if dataset.present?
      Jsonata.new(expr, JSON.parse(File.read("./spec/fixtures/#{dataset}.json")))
    else
      Jsonata.new(expr, data)
    end
  end
end
