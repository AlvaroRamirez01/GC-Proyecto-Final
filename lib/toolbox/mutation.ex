defmodule Toolbox.Mutation do
  @moduledoc """
  Continene funciones con diferentes estrategias para realizar la mutación.
  La mutación es una etapa necesaria para mantener la diversidad genética de los
  cromosomas de una población de un algoritmo genético.

  La idea es generar cambios al azar a algunos o todos los genes en un
  cromosoma, introduciendo diversidad genética en la población.
  """
  alias Types.Chromosome

  def flip(chromosome, _opts \\ []) do
    genes =
      chromosome.genes
      |> Enum.map(&Bitwise.bxor(&1, 1))

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def scramble(chromosome, _opts \\ []) do
    genes =
      chromosome.genes
      |> Enum.shuffle()

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def gaussian(chromosome, _opts \\ []) do
    mu = Enum.sum(chromosome.genes) / length(chromosome.genes)

    sigma =
      chromosome.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(length(chromosome.genes))
      # |> :math.sqrt()

    genes =
      chromosome.genes
      |> Enum.map(fn _ -> :rand.normal(mu, sigma) end)

    %Chromosome{genes: genes, size: chromosome.size}
  end
end
