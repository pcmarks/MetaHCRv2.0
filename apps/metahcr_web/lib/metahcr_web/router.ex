defmodule MetahcrWeb.Router do
  use MetahcrWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MetaHcrWeb.Authorization, repo: MetaHcr.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug MetaHcrWeb.Authorization, repo: MetaHcr.Repo
  end

  scope "/", MetahcrWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end
  scope "/login", MetahcrWeb.Authorization do
    pipe_through :api

    post "/", LoginController, :index
  end
  scope "/browse", MetahcrWeb.Browse, as: :browse do
    pipe_through :api

    get "/", CountController, :count_all
    resources "/investigation", InvestigationController
    resources "/sample", SampleController
    resources "/attribute", AttributeController
    resources "/biological_analysis", BiologicalAnalysisController, only: [:index]
    resources "/organism", OrganismController, only: [:index]
    resources "/single_gene_analysis", SingleGeneAnalysisController, only: [:index]
    resources "/single_gene_result", SingleGeneResultController, only: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", MetahcrWeb do
  #   pipe_through :api
  # end
end
