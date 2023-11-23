defmodule ChangelogrWeb.ChangelogLive.Index do
  use ChangelogrWeb, :live_view

  alias Phoenix.LiveView.AsyncResult

  alias Changelogr.Kernels
  alias Changelogr.Kernels.Changelog

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:async_result, %AsyncResult{})
      |> assign(:messages, [])

    {:ok, stream(socket, :changelogs, Kernels.list_changelogs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Changelog")
    |> assign(:changelog, Kernels.get_changelog!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Changelog")
    |> assign(:changelog, %Changelog{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Changelogs")
    |> assign(:changelog, nil)
  end

  @impl true
  def handle_info({ChangelogrWeb.ChangelogLive.FormComponent, {:saved, changelog}}, socket) do
    {:noreply, stream_insert(socket, :changelogs, changelog)}
  end

  def handle_info({:task_message, message}, socket) do
    socket =
      socket
      |> assign(:messages, [message | socket.assigns.messages])

    IO.inspect(socket.assigns)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    changelog = Kernels.get_changelog!(id)
    {:ok, _} = Kernels.delete_changelog(changelog)

    {:noreply, stream_delete(socket, :changelogs, changelog)}
  end

  def handle_event("process", %{"id" => id}, socket) do
    changelog = Kernels.get_changelog!(id)

    IO.inspect(changelog)

    # {:ok, _} = Kernels.delete_changelog(changelog)
    r = Changelogr.one(changelog.kernel_version)

    r
    |> Enum.each(fn x ->
      Ecto.build_assoc(changelog, :commits, %{
        commit: x.commit,
        title: x.title,
        # |> Enum.intersperse("\n\n") |> List.to_string()
        body: x.body
      })
      |> Changelogr.Repo.insert!()
    end)

    {:noreply, push_navigate(socket, to: ~p"/commits")}
  end

  def handle_event("start_processing", %{"id" => id}, socket) do
    changelog = Kernels.get_changelog!(id)

    socket =
      socket
      |> assign(:messages, [])
      |> assign(:changelog, changelog)
      |> start_test_task(changelog)

    {:noreply, socket}
  end

  def handle_event("cancel", _params, socket) do
    socket =
      socket
      |> cancel_async(:running_task)
      |> assign(:async_result, %AsyncResult{})
      |> put_flash(:info, "Cancelled")

    {:noreply, socket}
  end

  def start_test_task(socket, changelog) do
    live_view_pid = self()

    r = Changelogr.one(changelog.kernel_version)

    socket
    |> assign(:async_result, AsyncResult.loading())
    |> start_async(:running_task, fn ->
      # the code to run async)


      Enum.each(r, fn x ->
        Ecto.build_assoc(changelog, :commits, %{
          commit: x.commit,
          title: x.title,
          body: x.body
        })
        |> Changelogr.Repo.insert!()
        #IO.puts("ASYNC PROCESSING COMMIT #{x.commit}")
        send(live_view_pid, {:task_message, "PERSISTED #{x.commit}"})

      end)

      # return a small, controlled value
      :ok
    end)
  end

  def handle_async(:running_task, {:ok, :ok = _success_result}, socket) do
    socket =
      socket
      |> put_flash(:info, "Completed!")
      |> assign(:async_result, AsyncResult.ok(%AsyncResult{}, :ok))

    {:noreply, socket}
  end

  def handle_async(:running_task, {:ok, {:error, reason}}, socket) do
    socket =
      socket
      |> put_flash(:error, reason)
      |> assign(:async_result, AsyncResult.failed(%AsyncResult{}, reason))

    {:noreply, socket}
  end

  def handle_async(:running_task, {:exit, reason}, socket) do
    socket =
      socket
      |> put_flash(:error, "Task failed: #{inspect(reason)}")
      |> assign(:async_result, %AsyncResult{})

    {:noreply, socket}
  end
end
