defmodule ChangelogrWeb.ChangelogLive.FormComponent do
  use ChangelogrWeb, :live_component

  alias Changelogr.Kernels

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage changelog records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="changelog-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:kernel_version]} type="text" label="Kernel version" />
        <%#
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:date]} type="datetime-local" label="Date" />
        <.input field={@form[:timestamp]} type="datetime-local" label="Timestamp" />
        %>
        <:actions>
          <.button phx-disable-with="Saving..."><%= gettext("Save") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{changelog: changelog} = assigns, socket) do
    changeset = Kernels.change_changelog(changelog)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"changelog" => changelog_params}, socket) do
    changeset =
      socket.assigns.changelog
      |> Kernels.change_changelog(changelog_params)
      |> Map.put(:action, :validate)

    IO.inspect Map.get(changelog_params, "kernel_version") # FIXME

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"changelog" => changelog_params}, socket) do
    IO.inspect changelog_params
    v = Map.get(changelog_params, "kernel_version")

    {:ok, cl} = Changelogr.Fetcher.fetch_changelog_for_version(v)

    IO.inspect cl

    changelog_params =
        changelog_params
        |> Map.put("url", cl.url)
        |> Map.put("date", cl.date)
        |> Map.put("timestamp", cl.timestamp)

    IO.inspect changelog_params

    save_changelog(socket, socket.assigns.action, changelog_params)
  end

  defp save_changelog(socket, :edit, changelog_params) do
    case Kernels.update_changelog(socket.assigns.changelog, changelog_params) do
      {:ok, changelog} ->
        notify_parent({:saved, changelog})

        {:noreply,
         socket
         |> put_flash(:info, "Changelog updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_changelog(socket, :new, changelog_params) do
    case Kernels.create_changelog(changelog_params) do
      {:ok, changelog} ->
        notify_parent({:saved, changelog})

        {:noreply,
         socket
         |> put_flash(:info, "Changelog created successfully")
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
