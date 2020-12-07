defmodule Loom.Guardian do
  use Guardian, otp_app: :loom

  def subject_for_token(user, _claims) do
    {:ok, user}
  end

  def resource_from_claims(%{"sub" => name}) do
    {:ok, name}
  end
end
