defmodule IronfolkCombat.Misconduct do
  @moduledoc """
  Context for managing misconduct reports.
  """

  import Ecto.Query, warn: false
  alias IronfolkCombat.Repo
  alias IronfolkCombat.Misconduct.MisconductReport

  @pubsub IronfolkCombat.PubSub

  @doc """
  Lists misconduct reports with optional filtering.
  """
  def list_reports(opts \\ []) do
    MisconductReport
    |> apply_filters(opts)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
  end

  def count_pending_reports() do
    MisconductReport
    |> where([r], r.status == "PENDING")
    |> Repo.aggregate(:count, :id)
  end

  defp apply_filters(query, []), do: query

  defp apply_filters(query, [{:status, status} | rest]) when status != :all do
    query
    |> where([r], r.status == ^status)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [{:severity, severity} | rest]) when severity != :all do
    query
    |> where([r], r.severity == ^severity)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [_unknown | rest]) do
    apply_filters(query, rest)
  end

  @doc """
  Gets a single misconduct report by ID.
  """
  def get_report!(id), do: Repo.get!(MisconductReport, id)

  @doc """
  Creates a misconduct report.
  """
  def create_report(attrs \\ %{}) do
    result =
      %MisconductReport{}
      |> MisconductReport.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, report} ->
        broadcast_change({:report_created, report})
        {:ok, report}

      error ->
        error
    end
  end

  @doc """
  Updates a misconduct report's status.
  """
  def update_report_status(%MisconductReport{} = report, status) do
    result =
      report
      |> MisconductReport.changeset(%{status: status})
      |> Repo.update()

    case result do
      {:ok, updated_report} ->
        broadcast_change({:report_updated, updated_report})
        {:ok, updated_report}

      error ->
        error
    end
  end

  @doc """
  Updates a misconduct report's severity level.
  """
  def update_report_severity(%MisconductReport{} = report, severity) do
    result =
      report
      |> MisconductReport.changeset(%{severity: severity})
      |> Repo.update()

    case result do
      {:ok, updated_report} ->
        broadcast_change({:report_updated, updated_report})
        {:ok, updated_report}

      error ->
        error
    end
  end

  @doc """
  Adds an admin note to a misconduct report.
  Admin notes are stored as an array of maps.
  """
  def add_admin_note(%MisconductReport{} = report, note_text, admin_name) do
    new_note = %{
      "timestamp" =>
        NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_iso8601(),
      "admin" => admin_name,
      "note" => note_text
    }

    updated_notes = (report.admin_notes || []) ++ [new_note]

    result =
      report
      |> MisconductReport.changeset(%{admin_notes: updated_notes})
      |> Repo.update()

    case result do
      {:ok, updated_report} ->
        broadcast_change({:report_updated, updated_report})
        {:ok, updated_report}

      error ->
        error
    end
  end

  @doc """
  Deletes a misconduct report.
  """
  def delete_report(%MisconductReport{} = report) do
    Repo.delete(report)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking misconduct report changes.
  """
  def change_report(%MisconductReport{} = report, attrs \\ %{}) do
    MisconductReport.changeset(report, attrs)
  end

  # Broadcast changes to subscribed LiveViews
  defp broadcast_change({event, report}) do
    Phoenix.PubSub.broadcast(@pubsub, "misconduct_reports", {event, report})
  end

  @doc """
  Determines severity based on violation type and description.
  This is a helper function that can be used when creating reports.
  """
  def assess_severity(violation_type, immediate_threat) do
    cond do
      immediate_threat == true -> "HIGH"
      violation_type in ["PHYSICAL_VIOLENCE", "SEXUAL_HARASSMENT"] -> "HIGH"
      violation_type in ["VERBAL_ABUSE", "DISCRIMINATION"] -> "MEDIUM"
      true -> "LOW"
    end
  end
end
