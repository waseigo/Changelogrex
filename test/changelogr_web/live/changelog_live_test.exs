defmodule ChangelogrWeb.ChangelogLiveTest do
  use ChangelogrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Changelogr.KernelsFixtures

  @create_attrs %{
    date: "2023-11-19T20:49:00",
    kernel_version: "some kernel_version",
    timestamp: "2023-11-19T20:49:00Z",
    url: "some url"
  }
  @update_attrs %{
    date: "2023-11-20T20:49:00",
    kernel_version: "some updated kernel_version",
    timestamp: "2023-11-20T20:49:00Z",
    url: "some updated url"
  }
  @invalid_attrs %{date: nil, kernel_version: nil, timestamp: nil, url: nil}

  defp create_changelog(_) do
    changelog = changelog_fixture()
    %{changelog: changelog}
  end

  describe "Index" do
    setup [:create_changelog]

    test "lists all changelogs", %{conn: conn, changelog: changelog} do
      {:ok, _index_live, html} = live(conn, ~p"/changelogs")

      assert html =~ "Listing Changelogs"
      assert html =~ changelog.kernel_version
    end

    test "saves new changelog", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/changelogs")

      assert index_live |> element("a", "New Changelog") |> render_click() =~
               "New Changelog"

      assert_patch(index_live, ~p"/changelogs/new")

      assert index_live
             |> form("#changelog-form", changelog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#changelog-form", changelog: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/changelogs")

      html = render(index_live)
      assert html =~ "Changelog created successfully"
      assert html =~ "some kernel_version"
    end

    test "updates changelog in listing", %{conn: conn, changelog: changelog} do
      {:ok, index_live, _html} = live(conn, ~p"/changelogs")

      assert index_live |> element("#changelogs-#{changelog.id} a", "Edit") |> render_click() =~
               "Edit Changelog"

      assert_patch(index_live, ~p"/changelogs/#{changelog}/edit")

      assert index_live
             |> form("#changelog-form", changelog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#changelog-form", changelog: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/changelogs")

      html = render(index_live)
      assert html =~ "Changelog updated successfully"
      assert html =~ "some updated kernel_version"
    end

    test "deletes changelog in listing", %{conn: conn, changelog: changelog} do
      {:ok, index_live, _html} = live(conn, ~p"/changelogs")

      assert index_live |> element("#changelogs-#{changelog.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#changelogs-#{changelog.id}")
    end
  end

  describe "Show" do
    setup [:create_changelog]

    test "displays changelog", %{conn: conn, changelog: changelog} do
      {:ok, _show_live, html} = live(conn, ~p"/changelogs/#{changelog}")

      assert html =~ "Show Changelog"
      assert html =~ changelog.kernel_version
    end

    test "updates changelog within modal", %{conn: conn, changelog: changelog} do
      {:ok, show_live, _html} = live(conn, ~p"/changelogs/#{changelog}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Changelog"

      assert_patch(show_live, ~p"/changelogs/#{changelog}/show/edit")

      assert show_live
             |> form("#changelog-form", changelog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#changelog-form", changelog: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/changelogs/#{changelog}")

      html = render(show_live)
      assert html =~ "Changelog updated successfully"
      assert html =~ "some updated kernel_version"
    end
  end
end
