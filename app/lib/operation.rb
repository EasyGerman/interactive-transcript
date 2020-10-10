class Operation < CustomStruct

  def self.call(params)
    new(params).call
  end

end
