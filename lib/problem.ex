defmodule Genetics.Problem do
  @moduledoc """
  Definición del comportamiento de un problema genético, con las funciones
  especificas que cada problema debe de proveer.
    - Función 'Fitness': Como evaluar al individuo. Regresa una puntuación del
      individuo.
    - Genotipo: Como crear un nuevo individuo.
    - Condicion de terminación: Cuando un algoritmo debe de parar.

    Estas funciones permiten 'hyperparametros' para controlar como el algoritmo
    funciona, como el tamaño de la población o la tasa de mutacion.
    Cada implementación de un problema puede definir sus propios
    hiperparametros.
  """
  @typedoc """
  Tipo Hyperparameters.
  Hyperparameters son representados como un `Keyword`. Son opcionales.
  """
  @type hyperparameters :: keyword()
  alias Types.Chromosome

  @doc """
  Genera un nuevo individuo.
  """
  @callback genotype(hyperparameters) :: Chromosome.t()

  @doc """
  La función fitness determina que tan apto es un individuo(la habilidad de
  competir con otros individuos).
  Returns: Una puntuación para cada individuo.
  """
  @callback fitness_function(Chromosome.t(), hyperparameters) :: number()

  @doc """
  Define cuando un algoritmo debe de detenerse al regresar true, o continuar
  en otro caso.
  """
  @callback terminate?(Enum.t(), integer(), hyperparameters) :: boolean()
end
