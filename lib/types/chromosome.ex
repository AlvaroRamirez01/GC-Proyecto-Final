defmodule Types.Chromosome do
  @moduledoc """
  Definición del tipo cromosoma que representa una sola solución.
  Un cromosoma representa una solucion al problema que se está tratandod de resolver.
  Las soluciones se codifican en una colleción de genes. El cromosoma se evalúa basado en algún criterio que uno debe de definir.

  Los cromosomas deben de contener toda la información necesaria para evaluarse a si mismo.
  """

  @typedoc """
  Chromosome type.
  Chromosomes son representados como `%Chromosome{}`. Por lo menos se necesita definir `:genes`.

  # Campos
    - `:genes`: `Enum` conteniendo la representación del genotipo.
    - `:id`: `string` id unico del cromosoma.
    - `:size`: `non_neg_integer` representa el tamaño del cromosoma.
    - `:age`: `non_neg_integer` representa la edad del cromosoma.
    - `:fitness`: `number` representa la fitness del cromosoma.
  """
  @type t :: %__MODULE__{
          genes: Enum.t(),
          id: String.t(),
          size: non_neg_integer(),
          age: non_neg_integer(),
          fitness: number()
        }

  @enforce_keys :genes
  @derive {Inspect, only: [:genes, :fitness, :age]}
  defstruct [
    :genes,
    id: Base.encode16(:crypto.strong_rand_bytes(64)),
    size: 0,
    fitness: 0,
    age: 0
  ]
end
