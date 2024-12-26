def build_jsonata(expr:, dataset: nil, data: "")
  data = JSON.parse(File.read("./spec/fixtures/#{dataset}.json")) if dataset.present?
  [Jsonata.new(expr), data]
end
