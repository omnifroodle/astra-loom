defmodule Loom.Thread do

  def to_color(string) do
    # string to HSL color hash based on https://github.com/zenozeng/color-hash
    s_values = ["35%", "50%", "65%"]
    l_values = s_values
    hash = Enum.sum(to_charlist(string))
    hue = rem(hash, 359)
    s_hash = div(hash, 360)
    saturation = Enum.at(s_values, rem(s_hash, 3))
    l_hash = div(s_hash, 3)
    lightness = Enum.at(l_values, rem(l_hash, 3))
    [h: hue, s: saturation, l: lightness]
    "hsl(#{hue}, #{saturation}, #{lightness})"
  end

    
  def update_thread(user_id, thread, enabled) do
    {:ok, _} = Astra.Document.put_sub_doc("loom", "users", user_id, "threads/#{thread}", %{"enabled" => enabled})
  end
  
  def get_threads(user_id) do
    Astra.Document.get_sub_doc("loom", "users", user_id, "threads")
  end
end
