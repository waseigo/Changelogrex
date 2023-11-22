defmodule ChangelogrWeb.CommitLiveTest do
  use ChangelogrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Changelogr.CommitsFixtures

  @create_attrs %{body: "some body", commit: "some commit"}
  @update_attrs %{body: "some updated body", commit: "some updated commit"}
  @invalid_attrs %{body: nil, commit: nil}

  defp create_commit(_) do
    commit = commit_fixture()
    %{commit: commit}
  end

  describe "Index" do
    setup [:create_commit]

    test "lists all commits", %{conn: conn, commit: commit} do
      {:ok, _index_live, html} = live(conn, ~p"/commits")

      assert html =~ "Listing Commits"
      assert html =~ commit.body
    end

    test "saves new commit", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/commits")

      assert index_live |> element("a", "New Commit") |> render_click() =~
               "New Commit"

      assert_patch(index_live, ~p"/commits/new")

      assert index_live
             |> form("#commit-form", commit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#commit-form", commit: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/commits")

      html = render(index_live)
      assert html =~ "Commit created successfully"
      assert html =~ "some body"
    end

    test "updates commit in listing", %{conn: conn, commit: commit} do
      {:ok, index_live, _html} = live(conn, ~p"/commits")

      assert index_live |> element("#commits-#{commit.id} a", "Edit") |> render_click() =~
               "Edit Commit"

      assert_patch(index_live, ~p"/commits/#{commit}/edit")

      assert index_live
             |> form("#commit-form", commit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#commit-form", commit: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/commits")

      html = render(index_live)
      assert html =~ "Commit updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes commit in listing", %{conn: conn, commit: commit} do
      {:ok, index_live, _html} = live(conn, ~p"/commits")

      assert index_live |> element("#commits-#{commit.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#commits-#{commit.id}")
    end
  end

  describe "Show" do
    setup [:create_commit]

    test "displays commit", %{conn: conn, commit: commit} do
      {:ok, _show_live, html} = live(conn, ~p"/commits/#{commit}")

      assert html =~ "Show Commit"
      assert html =~ commit.body
    end

    test "updates commit within modal", %{conn: conn, commit: commit} do
      {:ok, show_live, _html} = live(conn, ~p"/commits/#{commit}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Commit"

      assert_patch(show_live, ~p"/commits/#{commit}/show/edit")

      assert show_live
             |> form("#commit-form", commit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#commit-form", commit: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/commits/#{commit}")

      html = render(show_live)
      assert html =~ "Commit updated successfully"
      assert html =~ "some updated body"
    end
  end
end
