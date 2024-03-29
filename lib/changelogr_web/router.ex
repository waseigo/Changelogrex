defmodule ChangelogrWeb.Router do
  use ChangelogrWeb, :router

  import ChangelogrWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChangelogrWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChangelogrWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChangelogrWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:changelogr, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChangelogrWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ChangelogrWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ChangelogrWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ChangelogrWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Changelogs

    live "/changelogs/:id/edit", ChangelogLive.Index, :edit
    live "/changelogs/:id/show/edit", ChangelogLive.Show, :edit

    # Fetchops
    live "/fetchops/new", FetchopLive.Index, :new
    live "/fetchops/:id/edit", FetchopLive.Index, :edit
    live "/fetchops/:id/show/edit", FetchopLive.Show, :edit

    # Commits
    live "/commits/new", CommitLive.Index, :new
    live "/commits/:id/edit", CommitLive.Index, :edit
    live "/commits/:id/show/edit", CommitLive.Show, :edit

    live_session :require_authenticated_user,
      on_mount: [{ChangelogrWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ChangelogrWeb do
    pipe_through [:browser]

    # Changelogs
    live "/changelogs/new", ChangelogLive.Index, :new
    live "/changelogs", ChangelogLive.Index, :index
    live "/changelogs/:id", ChangelogLive.Show, :show

    # Fetchops
    live "/fetchops", FetchopLive.Index, :index
    live "/fetchops/:id", FetchopLive.Show, :show

    # Commits
    live "/commits", CommitLive.Index, :index
    live "/commits/:id", CommitLive.Show, :show

    # Instructions
    live "/instructions", InstructionLive.Index, :index
    live "/instructions/new", InstructionLive.Index, :new
    live "/instructions/:id/edit", InstructionLive.Index, :edit

    live "/instructions/:id", InstructionLive.Show, :show
    live "/instructions/:id/show/edit", InstructionLive.Show, :edit

    # Authentication
    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ChangelogrWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
