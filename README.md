<br>
<table>
  <tr>
    <td><img src="images/unam.png" alt="Logo Universidad" width="142"/></td>
    <td style="text-align: center;">
    UNIVERSIDAD NACIONAL AUTÓNOMA DE MÉXICO <br>
      FACULTAD DE CIENCIAS<br>
      GENÓMICA COMPUTACIONAL
    </td>
    <td><img src="images/ciencias.png" alt="Logo Universidad" width="142"></  <td style="text-align: center;">
  </tr>
</table>

## Información General

- **Semestre**: 2024-2
- **Integrantes del Curso**:

  - Francisco Contreras Ibarra
  - Alvaro Ramírez Lopez
  - José Ethan Ortega González
- **Profesores**:

  - **Titular**: Sergio Hernández López
  - **Ayudantes**:
    - Rafael López Martínez
    - Jazmín de Jesús Santillán Manjarrez

## Objetivos generales

Este repositorio contiene el framework desarrollado en el curso de genómica computacional para algoritmos genéticos, nos basamos en el libro de *Genetic algorithms in elixir: Solve Problems Using Evolution* de *Moriarity, Sean.*

## Requisitos del sistema

Para compilar y ejecutar los archivos `ex` y `exs` debemos de contar con `erlang` y `elixir` instalados en el sistema.

Para instalar Elixir debamos un link de referencia para consultar la documentación oficial

[Docs Install Elixir-Lang](https://elixir-lang.org/install.html)

Asi como también recomendamos usar un gestor de versiones como lo es `kiex `

[Kiex - Elixir Version Manager](https://github.com/taylor/kiex)

Para este proyecto recomendamos usar la siguiente version:

```bash
Erlang/OTP 24 [erts-12.2.1] [source] [64-bit] [smp:20:20] [ds:20:20:10] [async-threads:1] [jit]

Elixir 1.16.3 (compiled with Erlang/OTP 24)
```

## Forma de ejecución

Desde la carpeta raíz deberán de tener a la vista el archivo `mix.exs`, para bajar todas las dependencias requeridas por el proyecto deberán de hacer el siguiente comando.

```bash
mix deps.get
```

Ahora para ejecutar el código deberán de hacer lo siguiente:

```bash
mix run scripts/penguin_simulation.exs
```



## Licencia

Toda la información y recursos proporcionados están bajo la licencia MIT a menos que se indique lo contrario.

---

© 2023 Universidad Nacional Autónoma de México. Todos los derechos reservados.
