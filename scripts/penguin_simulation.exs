defmodule PenguinSimulation do
  @behaviour Genetics.Problem
  alias Types.Chromosome

  @impl true
  def genotype(opts \\ []) do
    index = Keyword.get(opts, :index)
    initial_data = Map.fetch!(Keyword.get(opts, :initial_data), :data)
    gene = Enum.at(initial_data, index)

    %Chromosome{genes: gene, size: Enum.count(gene)}
  end

  @impl true
  def fitness_function(chromosome, opts \\ []) do
    initial_data = Keyword.get(opts, :initial_data)
    {scores, limit} = Map.fetch!(initial_data, Keyword.get(opts, :island, :biscoe))

    potential_individual =
      chromosome.genes
      |> Enum.zip(scores)
      |> Enum.map(fn {t, s} -> t * s end)
      |> Enum.sum()

    if potential_individual > limit, do: 0, else: potential_individual
  end

  @impl true
  def terminate?(_population, generations, opts \\ []) do
    generations_number = Keyword.get(opts, :generations, 20)

    generations == generations_number
  end

  def average_penguin(population) do
    genes = Enum.map(population, & &1.genes)
    fitnesses = Enum.map(population, & &1.fitness)
    ages = Enum.map(population, & &1.age)
    num_penguins = length(population)
    avg_fitness = Enum.sum(fitnesses) / num_penguins
    avg_age = Enum.sum(ages) / num_penguins

    avg_genes =
      genes
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&(Enum.sum(&1) / num_penguins))
      |> Enum.map(&Float.round(&1, 2))

    %Chromosome{genes: avg_genes, age: avg_age, fitness: avg_fitness}
  end
end

alias NimbleCSV.RFC4180, as: CSV

initial_data =
  Map.new()
  |> Map.put(
    :data,
    "datasets/cromosomas.csv"
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(
      &Enum.map(&1, fn row ->
        String.to_float(row)
      end)
    )
    |> Enum.to_list()
  )

island_data =
  [biscoe: [2.5, 0.0, -0.8, 0.2], dream: [1.3, -2.1, 0.0, 0.1], torgensen: [-1.4, 1.7, 2.3, 0.5]]
  |> Enum.map(fn {k, score} ->
    lst =
      for row <- initial_data.data do
        row
        |> Enum.zip(score)
        |> Enum.map(fn {t, s} -> t * s end)
        |> Enum.sum()
      end

    Map.new()
    |> Map.put(k, {score, Enum.sum(lst) / length(lst)})
  end)
  |> Enum.reduce(&Map.merge(&1, &2))

initial_data = initial_data |> Map.merge(island_data)

island = IO.gets("Inserta el nombre de la isla (biscoe, dream, torgensen): ")
island = case String.trim(IO.chardata_to_string(island)) do
  "biscoe" -> :biscoe
  "dream" -> :dream
  "torgensen" -> :torgensen
  _ ->  raise "Nombre de la isla invalida"
end

pinguinos =
  Genetics.run(PenguinSimulation,
    initial_data: initial_data,
    island: island,
    generations: 100,
    population_size: length(initial_data.data),
    tournament_size: 10,
    selection_rate: 0.9,
    mutation_rate: 0.1,
    reinsertion_rate: 0.1,
    selection_type: &Toolbox.Selection.tournament_no_duplicates/3,
    crossover_type: &Toolbox.Crossover.whole_arithmetic_crossover/3,
    mutation_type: &Toolbox.Mutation.gaussian/2,
    reinsert_type: &Toolbox.Reinsertion.elitist/4,
    statistics: %{average_penguin: &PenguinSimulation.average_penguin/1}
  )

IO.write("\n")
IO.puts("Pinguino más apto:")
IO.inspect(pinguinos)

{_, zero_gen_stats} = Utilities.Statistics.lookup(0)
{_, fivehundred_gen_stats} = Utilities.Statistics.lookup(50)
{_, onethousand_gen_stats} = Utilities.Statistics.lookup(100)
IO.puts("generation 0: ")
IO.inspect(zero_gen_stats.average_penguin)
IO.puts("generation 50: ")
IO.inspect(fivehundred_gen_stats.average_penguin)
IO.puts("generation 100: ")
IO.inspect(onethousand_gen_stats.average_penguin)

# stats =
#   :ets.tab2list(:statistics)
#   |> Enum.map(fn {gen, stats} -> [gen, stats.mean_fitness] end)

# {:ok, _cmd} =
#   Gnuplot.plot([
#     ~w(set autoscale)a,
#     [:set, :term, :pngcairo],
#     [:set, :output, "results/#{Atom.to_string(island)}_mean_fitness.png"],
#     [:set, :title, "mean fitness vs generation"],
#     [:plot, "-", :with, :points]
#   ], [stats])

# genealogy = Utilities.Genealogy.get_tree()
# {:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)
# {:ok, dotfile} = File.open("results/#{Atom.to_string(island)}_penguin_simulation.dot", [:write])
# :ok = IO.binwrite(dotfile, dot)
# :ok = File.close(dotfile)
# # IO.inspect(Graph.vertices(genealogy))
