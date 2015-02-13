class Whatever
  def initialize
    @foo = :bar
  end

  def bar
    "bar #{@foo}"
  end

  def baz
    "baz #{@foo}"
  end
end
