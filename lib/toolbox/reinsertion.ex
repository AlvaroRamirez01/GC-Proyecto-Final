defmodule Toolbox.Reinsertion do
  @moduledoc """
  Continene funciones con diferentes estrategias para realizar la reinserción.
  La reinserción es el proceso de tomar los cromosomas producidos por la
  selección, recombinación y la mutación e insertarlos de nuevo en la población
  para moverse en la siguiente generación.
  """

  def pure(_parents, offspring, _leftover, _opts \\ []), do: offspring

  def elitist(parents, offspring, leftover, opts \\ []) do
    old = parents ++ leftover
    reinsertion_rate = Keyword.get(opts, :reinsertion_rate, 0.2)
    n = floor(length(old) * reinsertion_rate)
    survivors = old |> Enum.sort_by(& &1.fitness, &>=/2) |> Enum.take(n)
    offspring ++ survivors
  end

  def uniform(parents, offspring, leftover, opts \\ []) do
    old = parents ++ leftover
    reinsertion_rate = Keyword.get(opts, :reinsertion_rate, 0.2)
    n = floor(length(old) * reinsertion_rate)
    survivors = old |> Enum.take_random(n)
    offspring ++ survivors
  end
end
