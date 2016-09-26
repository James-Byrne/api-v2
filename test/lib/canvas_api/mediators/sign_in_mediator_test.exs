defmodule CanvasAPI.SignInMediatorTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.SignInMediator, as: SIM

  import Mock
  import CanvasAPI.Factory

  @mock_team %{
    "id" => "team_id",
    "domain" => "test-team",
    "name" => "Test Team",
    "image_254" => "https://example.com/team-image.png"
  }

  @mock_user %{
    "id" => "user_id",
    "email" => "user@example.com",
    "name" => "User Name",
    "image_88" => "https://example.com/user-image.png"
  }

  setup do
    insert(:whitelisted_domain, domain: @mock_team["domain"])
    :ok
  end

  test "creates a new account, team, and user" do
    with_mock Slack.OAuth, [access: mock_access] do
      account =
        SIM.sign_in("ABCDEFG", account: nil)
        |> elem(1)
        |> Repo.preload([:teams, :users])

      [team] = account.teams
      [user] = account.users |> Repo.preload([:team])

      assert team.name == "Test Team"
      assert user.identity_token == "access_token"
      assert user.team == team
    end
  end

  test "attaches team and user to existing account" do
    account = insert(:account)

    with_mock Slack.OAuth, [access: mock_access] do
      {:ok, linked_account} = SIM.sign_in("ABCDEFG", account: account)
      assert linked_account.id == account.id
    end
  end

  test "allows only one user per team per account" do
    account = insert(:account)

    with_mock Slack.OAuth, [access: mock_access] do
      {:ok, _} = SIM.sign_in("ABCDEFG", account: account)
    end

    user = %{"id" => "user_2_id", "email" => "email", "name" => "Name"}

    with_mock Slack.OAuth, [access: mock_access(user: user)] do
      {:error, changeset} = SIM.sign_in("ABCDEFG", account: account)
      assert(
        {:team_id, {"already exists for this account", []}} in changeset.errors)
    end
  end

  defp mock_access(opts \\ []) do
    team = opts[:team] || @mock_team
    user = opts[:user] || @mock_user

    fn (client_id: _, client_secret: _, code: _, redirect_uri: _) ->
      {:ok,
        %{
          "access_token" => "access_token",
          "team" => team,
          "user" => user
        }
      }
    end
  end
end
