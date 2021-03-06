# Instruments.jl

This is a core package for the JuliaFinance ecosytem.

A financial instrument is a tradeable monetary contract that creates both an asset for one party and a liability for another. Examples of financial instruments include currencies, stocks, bonds, loans, derivatives, insurance policies, cryptocurrencies, etc. 

## `AbstractInstrument{S,C<:Currency}`

All financial instruments should be subtypes of `AbstractInstrument`, which is an abstract parametric type parameterized with the instrument's symbol identifier `S` and its `Currency`.

## `Cash{S,N} <: AbstractInstrument{S,currency(S))}`

When a currency is thought of as a financial instrument (as opposed to a mere label), we choose to refer to it as "Cash" as it would appear in a balance sheet. This package implements the `Cash` instrument with parameter `S` being the 3-character ISO 4167 alpha label of the currency as a `Symbol` and an integer `N` representing the number of decimal places in the currency (typically 0, 2 or 3).

Short constants are set up, matching the ISO 4167 names, so that you can use `USD` instead of `Cash{:USD,2}()`.

For example:

```julia
julia> import Instruments: JPY, USD, JOD

julia> typeof(JPY)
Cash{:JPY,0}

julia> typeof(USD)
Cash{:USD,2}

julia> typeof(JOD)
Cash{:JOD,3}
```

Although `Cash` is a singleton type, other financial instruments may contain various fields needed for cashflow projections, pricing, etc.

## `Position{I<:AbstractInstrument, A}`

A `Position` represents an amount of a financial instrument. For example, Microsoft stock (`MSFT`) is a financial instrument. A position could be 1,000 shares of `MSFT`.

In the case of currency, `USD` would be a financial instrument (`Cash`) and owning $1,000 would mean you own 1,000 units of `USD`, which can be expressed as

```julia
julia> 1000USD
1000.00USD

julia> typeof(1000USD)
Position{Cash{:USD,2},FixedDecimal{Int64,2}}
```

Simple algebraic operations can be performed on positions.

For example:

```julia
julia> using Instruments

julia> using Instruments: USD, JPY

julia> 10USD
10.00USD

julia> 10USD+20USD
30.00USD

julia> 5*20USD
100.00USD

julia> 100USD/5
20.00USD

julia> 100USD/5USD
FixedDecimal{Int64,2}(20.00)

julia> 100JPY/5JPY
FixedDecimal{Int64,0}(20)

julia> 100USD+100JPY
ERROR: Can't add Positions of different Instruments USD, JPY
```

Note that algebraic operations on positions require the positions to be of the same instrument. In this case, they must be the same currency as indicated by the error in the last command above.

For more information, see

- [Currencies.jl](https://github.com/JuliaFinance/Currencies.jl.git)
- [Markets.jl](https://github.com/JuliaFinance/Markets.jl.git)
- [GeneralLedgers.jl](https://github.com/JuliaFinance/GeneralLedgers.jl.git)