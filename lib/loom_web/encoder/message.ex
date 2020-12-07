defimpl Jason.Encoder, for: Loom.Message do
  def encode(value, opts) do
    Jason.Encode.map(Map.take(value, [:room, :user, :id, :added, :message, :thread, :picture]), opts)
  end
end
