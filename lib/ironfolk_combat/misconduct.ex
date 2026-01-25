defmodule IronfolkCombat.Misconduct do
  @moduledoc """
  The Misconduct context - handles misconduct reporting and management.
  """
  import Ecto.Query, warn: false
  alias IronfolkCombat.Repo
  alias IronfolkCombat.Misconduct.MisconductReport, as: Report

  @doc """
  Gets a single report by ID.
  Returns nil if not found.
  """
  def get_report_by_id(id) do
    Repo.get(Report, id)
  end

  @doc """
  Gets a single report by ID. Raises if not found.
  """
  def get_report!(id) do
    Repo.get!(Report, id)
  end

  @doc """
  Lists reports by status.
  """
  def get_report_by_status(status \\ "pending") do
    Report
    |> where([r], r.status == ^status)
    |> Repo.all()
  end

  @doc """
  Lists misconduct reports with optional filtering.
  Options:
    - status: :all (default), "pending", "under_review", "resolved", "dismissed"
    - severity: "low", "medium", "high"
  """
  def list_reports(opts \\ []) do
    status = Keyword.get(opts, :status, :all)
    severity = Keyword.get(opts, :severity, :all)

    Report
    |> filter_by_status(status)
    |> filter_by_severity(severity)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
  end

  defp filter_by_status(query, :all), do: query
  defp filter_by_status(query, status), do: where(query, [r], r.status == ^status)

  defp filter_by_severity(query, :all), do: query
  defp filter_by_severity(query, severity), do: where(query, [r], r.severity == ^severity)

  @doc """
  Counts pending misconduct reports.
  """
  def count_pending_reports do
    Report
    |> where([r], r.status == "pending")
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Creates a new misconduct report.
  """
  def create_report(attrs \\ %{}) do
    %Report{}
    |> Report.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a report's status.
  Status can be: "pending", "under_review", "resolved", "dismissed"
  """
  def update_report_status(%Report{} = report, status) do
    report
    |> Report.changeset(%{status: status})
    |> Repo.update()
  end

  @doc """
  Updates a report with arbitrary attributes.
  """
  def update_report(%Report{} = report, attrs) do
    report
    |> Report.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Adds an admin note to a misconduct report.
  Admin notes are stored as a list of maps with: admin_id, note, timestamp
  """
  def add_admin_note(%Report{} = report, admin_id, note_text) do
    new_note = %{
      admin_id: admin_id,
      note: note_text,
      timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    existing_notes = report.admin_notes || []
    updated_notes = existing_notes ++ [new_note]

    report
    |> Report.changeset(%{admin_notes: updated_notes})
    |> Repo.update()
  end

  @doc """
  Deletes a misconduct report.
  """
  def delete_report(%Report{} = report) do
    Repo.delete(report)
  end

  @doc """
  Determines severity based on violation type and description.
  This is a helper function that can be used when creating reports.
  """
  def assess_severity(violation_type, immediate_threat) do
    cond do
      immediate_threat != "" and immediate_threat != nil -> "high"
      violation_type in ["physical_violence", "sexual_harassment"] -> "high"
      violation_type in ["verbal_abuse", "discrimination"] -> "medium"
      true -> "low"
    end
  end
end
