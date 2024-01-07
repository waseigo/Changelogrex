defmodule ChangelogrWeb.CommitLive.FormComponent do
  use ChangelogrWeb, :live_component

  alias Changelogr.Commits

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage commit records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="commit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="text" label="Commit" />
        <.input field={@form[:body]} type="text" label="Body" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Commit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{commit: commit} = assigns, socket) do
    changeset = Commits.change_commit(commit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"commit" => commit_params}, socket) do
    changeset =
      socket.assigns.commit
      |> Commits.change_commit(commit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"commit" => commit_params}, socket) do
    save_commit(socket, socket.assigns.action, commit_params)
  end

  defp save_commit(socket, :edit, commit_params) do
    case Commits.update_commit(socket.assigns.commit, commit_params) do
      {:ok, commit} ->
        notify_parent({:saved, commit})

        {:noreply,
         socket
         |> put_flash(:info, "Commit updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_commit(socket, :new, commit_params) do
    case Commits.create_commit(commit_params) do
      {:ok, commit} ->
        notify_parent({:saved, commit})

        {:noreply,
         socket
         |> put_flash(:info, "Commit created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
