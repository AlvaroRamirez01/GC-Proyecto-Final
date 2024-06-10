defmodule TigerSimulation do
  @behaviour Genetics.Problem
  alias Types.Chromosome

  @impl true
  def genotype(opts \\ []) do
    size = Keyword.get(opts, :size, 8)
    genes = for _ <- 1..size, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: size}
  end

  @impl true
  def fitness_function(chromosome, _opts \\ []) do
    tropic_scores = [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
    _tundra_scores = [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]
    traits = chromosome.genes

    traits
    |> Enum.zip(tropic_scores)
    |> Enum.map(fn {t, s} -> t * s end)
    |> Enum.sum()
  end

  @impl true
  def terminate?(_population, generation, _opts \\ []), do: generation == 1_000

  def average_tiger(population) do
    genes = Enum.map(population, & &1.genes)
    fitnesses = Enum.map(population, & &1.fitness)
    ages = Enum.map(population, & &1.age)
    num_tigers = length(population)
    avg_fitness = Enum.sum(fitnesses) / num_tigers
    avg_age = Enum.sum(ages) / num_tigers

    avg_genes =
      genes
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&(Enum.sum(&1) / num_tigers))
      |> Enum.map(&Float.round(&1, 2))

    %Chromosome{genes: avg_genes, age: avg_age, fitness: avg_fitness}
  end
end

tiger =
  Genetics.run(TigerSimulation,
    population_size: 20,
    selection_rate: 0.9,
    mutation_rate: 0.1,
    statistics: %{average_tiger: &TigerSimulation.average_tiger/1}
  )

IO.write("\n")
IO.inspect(tiger)

{_, zero_gen_stats} = Utilities.Statistics.lookup(0)
{_, fivehundred_gen_stats} = Utilities.Statistics.lookup(500)
{_, onethousand_gen_stats} = Utilities.Statistics.lookup(1000)
IO.inspect(zero_gen_stats.average_tiger)
IO.inspect(fivehundred_gen_stats.average_tiger)
IO.inspect(onethousand_gen_stats.average_tiger)

genealogy = Utilities.Genealogy.get_tree()
IO.inspect(Graph.vertices(genealogy))
