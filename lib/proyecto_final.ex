defmodule Genetics do
  @moduledoc """
  Estructura de un algoritmo genético en Elixir.

  The process of creating an algorithm can be thought of in three phases:
    1. Problem Definition
    2. Evolution Definition
    3. Algorithm Execution

  Para definir un `Problem` se tiene que definir las siguientes funciones especificas:
    1. Define el espacio de soluciones (`genotype/1`): Como generar un nuevo individuo de tu problema.
    2. Define tu función objetivo (`fitness_function/2`): Como evaluar cada individuo.
    3. Define tu condición de terminación (`terminate?/2`): Cuando un algoritmo debe de terminar.

  ## Implementando un problema
  Un problema genético basico consiste de: `genotype/0`, `fitness_function/1`, and `terminate?/1`.
  ```
  defmodule OneMax do
    @behaviour Genetics.Problem
    alias Types.Chromosome

    @impl true
    def genotype(opts \\ []) do
      size = Keyword.get(opts, :size, 10)
      genes = for _ <- 1..42, do: Enum.random(0..1)
      %Chromosome{genes: genes, size: size}
    end

    @impl true
    def fitness_function(chromosome, _opts \\ []), do: Enum.sum(chromosome.genes)

    @impl true
    def terminate?([best | _], _opts \\ []) do
      best.fitness == best.size
    end
  end
  ```

  Notese que en este caso se usa el hyperparámetro `size` para definir el tamaño del gen.

  ## Hyperparameters

  """
  alias Toolbox.{Crossover, Selection, Mutation, Reinsertion, Evaluate}

  require Logger

  @doc """
  Run a specific problem with optional `hyperparameters`.

  Check [Problem definition](lib/genetics/problem.ex) for more information about `hyperparameters`.
  """
  def run(problem, opts \\ []) do
    Logger.info("Running #{inspect(problem)}")
    init_statistics()
    # Logger.info("opts: #{inspect(opts)}")
    population = initialize(&problem.genotype/1, opts)
    first_generation = 0

    population
    |> evolve(problem, first_generation, opts)
  end

  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    population = for i <- 0..population_size - 1, do: genotype.(Keyword.put(opts, :index, i))
    # IO.gets("Population: #{inspect(population)}\nPress Enter to continue...")
    Utilities.Genealogy.add_chromosomes(population)
    population
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/2, opts)
    statistics(population, generation, opts)
    best = hd(population)
    # IO.write("\rCurrent Best: #{fitness_function.(best)}")
    # IO.gets("Population evolved: #{inspect(population)}\nCurrent Best: #{inspect(best)}\nPress Enter to continue...")

    if problem.terminate?(population, generation, opts) do
      IO.write("\r")
      best
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(children, opts)
      offspring = children ++ mutants
      new_population = reinsertion(parents, offspring, leftover, opts)
      evolve(new_population, problem, generation + 1, opts)
    end
  end

  def evaluate(population, fitness_function, opts \\ []) do
    evaluate_operator = Keyword.get(opts, :evaluate_type, &Evaluate.heuristic_evaluation/3)
    result = evaluate_operator.(population, fitness_function, opts)
    # IO.gets("Evaluate result: #{inspect(result)}\nPress Enter to continue...")
    result
  end

  def select(population, opts \\ []) do
    select_operator = Keyword.get(opts, :select_type, &Selection.elite/3)
    select_rate = Keyword.get(opts, :select_rate, 0.8)

    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n + 1

    parents = select_operator.(population, n, opts)
    leftover = population |> MapSet.new() |> MapSet.difference(MapSet.new(parents))

    parents = parents |> Enum.chunk_every(2) |> Enum.map(&List.to_tuple(&1))
    result = {parents, MapSet.to_list(leftover)}
    # IO.gets("Select result: #{inspect(result)}\nPress Enter to continue...")
    result
  end

  def crossover(population, opts \\ []) do
    crossover_operator = Keyword.get(opts, :crossover_type, &Crossover.single_point_crossover/3)

    result =
      population
      |> Enum.reduce(
        [],
        fn {p1, p2}, acc ->
          {c1, c2} = crossover_operator.(p1, p2, opts)
          Utilities.Genealogy.add_chromosome(p1, p2, c1)
          Utilities.Genealogy.add_chromosome(p1, p2, c2)
          [c1, c2 | acc]
        end
      )

    # IO.gets("Crossover result: #{inspect(result)}\nPress Enter to continue...")
    result
  end

  def mutation(population, opts \\ []) do
    mutation_operator = Keyword.get(opts, :mutation_type, &Mutation.scramble/2)
    mutation_probability = Keyword.get(opts, :mutation_probability, 0.05)
    n = floor(length(population) * mutation_probability)

    result =
      population
      |> Enum.take_random(n)
      |> Enum.map(fn chromosome ->
        mutant = mutation_operator.(chromosome, opts)
        Utilities.Genealogy.add_chromosome(chromosome, mutant)
        mutant
      end)

    # IO.gets("Mutation result: #{inspect(result)}\nPress Enter to continue...")

    result
  end

  def reinsertion(parents, offspring, leftover, opts \\ []) do
    reinsert_operator = Keyword.get(opts, :reinsert_type, &Reinsertion.pure/4)
    reinsert_operator.(parents, offspring, leftover, opts)
  end

  defp init_statistics(), do: Utilities.Statistics.clean()

  defp statistics(population, generation, opts) do
    default_stats = [
      min_fitness: &Enum.min_by(&1, fn c -> c.fitness end).fitness,
      max_fitness: &Enum.max_by(&1, fn c -> c.fitness end).fitness,
      mean_fitness: &(Enum.sum(Enum.map(&1, fn c -> c.fitness end)) / length(&1))
    ]

    stats = Keyword.get(opts, :statistics, default_stats)

    stats_map =
      stats |> Enum.reduce(%{}, fn {key, func}, acc -> Map.put(acc, key, func.(population)) end)

    Utilities.Statistics.insert(generation, stats_map)
  end
end
