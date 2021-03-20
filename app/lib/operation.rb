class Operation < CustomStruct

  extend Memoist

  def self.call(params)
    new(params).call
  end

end
