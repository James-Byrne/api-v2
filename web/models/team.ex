defmodule CanvasAPI.Team do
  use CanvasAPI.Web, :model

  alias CanvasAPI.ImageMap

  schema "teams" do
    field :domain, :string
    field :images, :map, default: %{}
    field :name, :string
    field :slack_id, :string

    many_to_many :accounts, CanvasAPI.Account, join_through: "users"
    has_many :canvases, CanvasAPI.Canvas
    has_many :users, CanvasAPI.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain, :name, :slack_id])
    |> validate_required([:domain, :name, :slack_id])
    |> put_change(:images, ImageMap.image_map(params))
  end
end