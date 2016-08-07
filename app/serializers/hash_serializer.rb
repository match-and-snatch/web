class HashSerializer
  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    return {}.with_indifferent_access unless hash
    (JSON.parse(hash) || {}).with_indifferent_access
  end
end
