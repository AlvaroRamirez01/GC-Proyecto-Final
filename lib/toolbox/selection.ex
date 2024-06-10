defmodule Toolbox.Selection do
  @moduledoc """
  Continene funciones con diferentes estrategias para realizar la selección.
  La selección es la etapa de un algoritmo genético donde cromosomas son
  escogidos para después ser reproducidos
  """

  require Logger

  def elite(population, candidates, _opts \\ []) do
    population
    |> Enum.take(candidates)
  end

  def random(population, candidates, _opts \\ []) do
    population
    |> Enum.take_random(candidates)
  end

  def tournament(population, candidates, opts \\ []) do
    tournament_size = Keyword.get(opts, :tournament_size, 3)

    0..candidates
    |> Enum.map(fn _ ->
      population |> Enum.take_random(tournament_size) |> Enum.max_by(& &1.fitness)
    end)
  end

  def tournament_no_duplicates(population, candidates, opts \\ []) do
    tournament_size = Keyword.get(opts, :tournament_size, 3)

    selected = MapSet.new()
    tournament_helper(population, candidates, tournament_size, selected)
  end

  defp tournament_helper(population, n, tournsize, selected) do
    if MapSet.size(selected) == n do
      MapSet.to_list(selected)
    else
      chosen =
        population
        |> Enum.take_random(tournsize)
        |> Enum.max_by(& &1.fitness)

      tournament_helper(population, n, tournsize, MapSet.put(selected, chosen))
    end
  end

  def roulette(population, candidates, _opts \\ []) do
    sum_fitness =
      population
      |> Enum.map(fn chromosome -> chromosome.fitness end)
      |> Enum.sum()

    0..(candidates - 1)
    |> Enum.map(fn _ ->
      u = :rand.uniform() * sum_fitness

      population
      |> Enum.reduce_while(
        0,
        fn chromosome, acc ->
          if chromosome.fitness + acc > u do
            {:halt, chromosome}
          else
            {:cont, chromosome.fitness + acc}
          end
        end
      )
    end)
  end
end
