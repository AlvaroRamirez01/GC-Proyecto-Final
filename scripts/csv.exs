defmodule CsvManipulator do
  alias NimbleCSV.RFC4180, as: CSV

  def run(input_file, output_file) do
    input_file
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&Enum.slice(&1, 2..5)) # solo quedarse con las columnas 3 a 6,
    |> CSV.dump_to_iodata()
    |> (&File.write!(output_file, &1)).()
  end
end

# To run the script
input_file = "datasets/palmerpenguins_extended.csv"
output_file = "datasets/cromosomas.csv"
CsvManipulator.run(input_file, output_file)
