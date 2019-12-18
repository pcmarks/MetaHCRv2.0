defmodule MetahcrWeb.Authorization.LoginController do
  use MetahcrWeb, :controller

  alias Metahcr.Authorization

  def index(conn, %{"_user" => user, "_password" => password}) do

    user = Authorization.get_user(user)
    username = ""
    username = user && user.username 
    status =
      if user do
        if Comeonin.Pbkdf2.checkpw(password, user.password) do
          "OK"
        else
          "FAILED"
        end
      else
        "NO SUCH USER"
      end
    render( conn, "loginstatus.json", %{"user" => username, status: status})
  end

end
