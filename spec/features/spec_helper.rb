def build_jsonata(expr:, dataset: nil, data: "")
  if dataset.present?
    Jsonata.new(expr, JSON.parse(File.read("./spec/fixtures/#{dataset}.json")))
  else
    Jsonata.new(expr, data)
  end
end
