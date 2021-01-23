class Txt
  def self.bullet(bullet_string, content)
    head, *rest = content.split("\n")
    indent = bullet_string.length + 1

    [
      "#{bullet_string} #{head}",
      *rest.map { |line| "#{' ' * indent}#{line}"},
    ].join("\n")
  end
end
