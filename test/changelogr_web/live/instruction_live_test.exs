defmodule ChangelogrWeb.InstructionLiveTest do
  use ChangelogrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Changelogr.AugmentationsFixtures

  @create_attrs %{json: true, model: "some model", prompt: "some prompt"}
  @update_attrs %{json: false, model: "some updated model", prompt: "some updated prompt"}
  @invalid_attrs %{json: false, model: nil, prompt: nil}

  defp create_instruction(_) do
    instruction = instruction_fixture()
    %{instruction: instruction}
  end

  describe "Index" do
    setup [:create_instruction]

    test "lists all instructions", %{conn: conn, instruction: instruction} do
      {:ok, _index_live, html} = live(conn, ~p"/instructions")

      assert html =~ "Listing Instructions"
      assert html =~ instruction.model
    end

    test "saves new instruction", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/instructions")

      assert index_live |> element("a", "New Instruction") |> render_click() =~
               "New Instruction"

      assert_patch(index_live, ~p"/instructions/new")

      assert index_live
             |> form("#instruction-form", instruction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#instruction-form", instruction: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/instructions")

      html = render(index_live)
      assert html =~ "Instruction created successfully"
      assert html =~ "some model"
    end

    test "updates instruction in listing", %{conn: conn, instruction: instruction} do
      {:ok, index_live, _html} = live(conn, ~p"/instructions")

      assert index_live |> element("#instructions-#{instruction.id} a", "Edit") |> render_click() =~
               "Edit Instruction"

      assert_patch(index_live, ~p"/instructions/#{instruction}/edit")

      assert index_live
             |> form("#instruction-form", instruction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#instruction-form", instruction: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/instructions")

      html = render(index_live)
      assert html =~ "Instruction updated successfully"
      assert html =~ "some updated model"
    end

    test "deletes instruction in listing", %{conn: conn, instruction: instruction} do
      {:ok, index_live, _html} = live(conn, ~p"/instructions")

      assert index_live |> element("#instructions-#{instruction.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#instructions-#{instruction.id}")
    end
  end

  describe "Show" do
    setup [:create_instruction]

    test "displays instruction", %{conn: conn, instruction: instruction} do
      {:ok, _show_live, html} = live(conn, ~p"/instructions/#{instruction}")

      assert html =~ "Show Instruction"
      assert html =~ instruction.model
    end

    test "updates instruction within modal", %{conn: conn, instruction: instruction} do
      {:ok, show_live, _html} = live(conn, ~p"/instructions/#{instruction}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Instruction"

      assert_patch(show_live, ~p"/instructions/#{instruction}/show/edit")

      assert show_live
             |> form("#instruction-form", instruction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#instruction-form", instruction: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/instructions/#{instruction}")

      html = render(show_live)
      assert html =~ "Instruction updated successfully"
      assert html =~ "some updated model"
    end
  end
end
