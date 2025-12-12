defmodule IronfolkCombat.Misconduct do
  import Ecto.Query, warn: false
  alias IronfolkCombat.Repo
  alias IronfolkCombat.Misconduct.MisconductReport, as: Report

  def get_report_by_id(id) do
    Repo.get(Report, id)
  end

  def get_report_by_status(status \\ "pending") do
    Repo.get(Report, status)
  end

  def list_reports do
    Repo.all(Report)
  end

  def create_report(attrs \\ %{}) do
    %Report{}
    |> Report.changeset(attrs)
    |> Repo.insert()
  end

  def update_report_status(%Report{} = report, attrs) do
    case report |> Report.changeset(attrs) |> Repo.update() do
      {:ok, _report} = result -> result
      error -> error
    end
  end
end
