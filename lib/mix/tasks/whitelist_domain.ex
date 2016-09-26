defmodule Mix.Tasks.CanvasApi.WhitelistDomain do
  use Mix.Task

  import Ecto.Query, only: [from: 2]
  alias CanvasAPI.Repo
  alias CanvasAPI.WhitelistedSlackDomain, as: SlackDomain

  @moduledoc """
  Whitelist a Slack team's domain to allow Sign In With Slack to Canvas.

  ## Examples

      mix canvas_api.whitelist_domain usecanvas
  """

  @shortdoc "Whitelist a Slack team's domain."

  def run([domain]) do
    Mix.Task.run("app.start", [])

    from(d in SlackDomain, where: d.domain == ^domain)
    |> Repo.one
    |> case do
      nil -> %SlackDomain{}
      domain -> domain
    end
    |> SlackDomain.changeset(%{domain: domain})
    |> Repo.insert_or_update!
  end
end
