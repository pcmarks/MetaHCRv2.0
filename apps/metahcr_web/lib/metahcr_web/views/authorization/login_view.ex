defmodule MetahcrWeb.Authorization.LoginView do
  use MetahcrWeb, :view

  def render("loginstatus.json", %{"user" => user, status: status}) do
    %{user: user, status: status}
  end
end
