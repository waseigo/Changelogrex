defmodule ChangelogrWeb.FetchopLiveTest do
  use ChangelogrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Changelogr.FetchopsFixtures

  @create_attrs %{errors: "some errors", status: 42, timestamp: "2023-11-19T22:17:00Z", url: "some url"}
  @update_attrs %{errors: "some updated errors", status: 43, timestamp: "2023-11-20T22:17:00Z", url: "some updated url"}
  @invalid_attrs %{errors: nil, status: nil, timestamp: nil, url: nil}

  defp create_fetchop(_) do
    fetchop = fetchop_fixture()
    %{fetchop: fetchop}
  end

  describe "Index" do
    setup [:create_fetchop]

    test "lists all fetchops", %{conn: conn, fetchop: fetchop} do
      {:ok, _index_live, html} = live(conn, ~p"/fetchops")

      assert html =~ "Listing Fetchops"
      assert html =~ fetchop.errors
    end

    test "saves new fetchop", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/fetchops")

      assert index_live |> element("a", "New Fetchop") |> render_click() =~
               "New Fetchop"

      assert_patch(index_live, ~p"/fetchops/new")

      assert index_live
             |> form("#fetchop-form", fetchop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#fetchop-form", fetchop: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/fetchops")

      html = render(index_live)
      assert html =~ "Fetchop created successfully"
      assert html =~ "some errors"
    end

    test "updates fetchop in listing", %{conn: conn, fetchop: fetchop} do
      {:ok, index_live, _html} = live(conn, ~p"/fetchops")

      assert index_live |> element("#fetchops-#{fetchop.id} a", "Edit") |> render_click() =~
               "Edit Fetchop"

      assert_patch(index_live, ~p"/fetchops/#{fetchop}/edit")

      assert index_live
             |> form("#fetchop-form", fetchop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#fetchop-form", fetchop: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/fetchops")

      html = render(index_live)
      assert html =~ "Fetchop updated successfully"
      assert html =~ "some updated errors"
    end

    test "deletes fetchop in listing", %{conn: conn, fetchop: fetchop} do
      {:ok, index_live, _html} = live(conn, ~p"/fetchops")

      assert index_live |> element("#fetchops-#{fetchop.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#fetchops-#{fetchop.id}")
    end
  end

  describe "Show" do
    setup [:create_fetchop]

    test "displays fetchop", %{conn: conn, fetchop: fetchop} do
      {:ok, _show_live, html} = live(conn, ~p"/fetchops/#{fetchop}")

      assert html =~ "Show Fetchop"
      assert html =~ fetchop.errors
    end

    test "updates fetchop within modal", %{conn: conn, fetchop: fetchop} do
      {:ok, show_live, _html} = live(conn, ~p"/fetchops/#{fetchop}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Fetchop"

      assert_patch(show_live, ~p"/fetchops/#{fetchop}/show/edit")

      assert show_live
             |> form("#fetchop-form", fetchop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#fetchop-form", fetchop: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/fetchops/#{fetchop}")

      html = render(show_live)
      assert html =~ "Fetchop updated successfully"
      assert html =~ "some updated errors"
    end
  end
end
