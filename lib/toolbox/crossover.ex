defmodule Toolbox.Crossover do
  @moduledoc """
  Continene funciones con diferentes estrategias para realizar la recombinación.
  La recombinación es la etapa de un algoritmo genético donde dos padres generan
  nueva descendencia.
  """
  alias Types.Chromosome

  require Logger

  def single_point_crossover(parent_1, parent_2, opts \\ [])

  def single_point_crossover(
        parent_1 = %Chromosome{genes: []},
        parent_2 = %Chromosome{genes: []},
        _opts
      ),
      do: {parent_1, parent_2}

  def single_point_crossover(parent_1, parent_2, _opts) do
    cx_point = :rand.uniform(length(parent_1.genes))

    {{h1, t1}, {h2, t2}} =
      {Enum.split(parent_1.genes, cx_point), Enum.split(parent_2.genes, cx_point)}

    {%Chromosome{parent_1 | genes: h1 ++ t2}, %Chromosome{parent_2 | genes: h2 ++ t1}}
  end

  def order_one_crossover(parent_1, parent_2, _opts \\ []) do
    lim = Enum.count(parent_1.genes) - 1
    # Get random range​
    {i1, i2} =
      [:rand.uniform(lim), :rand.uniform(lim)]
      |> Enum.sort()
      |> List.to_tuple()

    # parent_2 contribution​
    slice1 = Enum.slice(parent_1.genes, i1..i2)
    slice1_set = MapSet.new(slice1)
    parent_2_contrib = Enum.reject(parent_2.genes, &MapSet.member?(slice1_set, &1))
    {head1, tail1} = Enum.split(parent_2_contrib, i1)

    # parent_1 contribution​
    slice2 = Enum.slice(parent_2.genes, i1..i2)
    slice2_set = MapSet.new(slice2)
    parent_1_contrib = Enum.reject(parent_1.genes, &MapSet.member?(slice2_set, &1))
    {head2, tail2} = Enum.split(parent_1_contrib, i1)

    # Make and return​
    {c1, c2} = {head1 ++ slice1 ++ tail1, head2 ++ slice2 ++ tail2}

    {%Chromosome{
       genes: c1,
       size: parent_1.size
     },
     %Chromosome{
       genes: c2,
       size: parent_2.size
     }}
  end

  def uniform(parent_1, parent_2, opts \\ []) do
    rate = Keyword.get(opts, :crossover_rate, 0.5)

    {c1, c2} =
      parent_1.genes
      |> Enum.zip(parent_2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < rate do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()

    {%Chromosome{parent_1 | genes: c1}, %Chromosome{parent_2 | genes: c2}}
  end

  def whole_arithmetic_crossover(parent_1, parent_2, opts \\ []) do
    alpha = Keyword.get(opts, :parent_porcentage, 0.5)
    {c1, c2} =
      parent_1.genes
      |> Enum.zip(parent_2.genes)
      |> Enum.map(fn {x, y} ->
        {
          x * alpha + y * (1 - alpha),
          x * (1 - alpha) + y * alpha
        }
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end
end
