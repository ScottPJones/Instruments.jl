"""
Instruments

This package provides the `AbstractInstrument` abstract type together with
`Cash` and `Postion` types for dealing with currencies and other financial 
instruments.

See README.md for the full documentation

Copyright 2020, Eric Forgy, Scott P. Jones and other contributors

Licensed under MIT License, see LICENSE.md
"""
module Instruments

using Currencies, FixedPointDecimals
import Currencies: symbol, unit, code, name

export Position, FixedDecimal
export AbstractInstrument, Cash
export Currencies, Currency

"""
This is an abstract type for `AbstractInstrument` such as `Cash`, `Stock`, etc.
"""
abstract type AbstractInstrument{S,C<:Currency} end
currency(::AbstractInstrument{S,C}) where {S,C} = C()
symbol(::AbstractInstrument{S}) where {S} = S

"""
`Cash` is a `AbstractInstrument`, that represents a particular currency as well
as the number of digits in the minor units, typically 0, 2, or 3
"""
struct Cash{S, N} <: AbstractInstrument{S,Currency{S}} end
Cash(S::Symbol) = Cash{S,unit(S)}()
Cash(C::Currency) = Cash(symbol(C))
unit(c::Cash) = unit(currency(c))
code(c::Cash) = code(currency(c))
name(c::Cash) = name(currency(c))

Base.show(io::IO, ::Cash{<:Currency{T}}) where {T} = print(io, string(T))

# # Set up short names for all of the currencies (as instances of the Cash instruments)
include(joinpath(@__DIR__, "..", "deps", "cashinstruments.jl"))

"""
Position represents a certain quantity of a particular financial instrument
"""
struct Position{I<:AbstractInstrument,A}
    instrument::I
    amount::A
    function Position(instrument::I, a) where {I<:AbstractInstrument}
        T = FixedDecimal{Int,unit(currency(instrument))}
        new{I,T}(instrument,T(a))
    end
end

# """
# Returns the financial instrument (as an instance) for a position
# """
instrument(p::Position) = p.instrument

# """
# Returns the currency (as an instance) of a position
# """
currency(p::Position) = currency(p.instrument)

Base.promote_rule(::Type{Position{F,A1}}, ::Type{Position{F,A2}}) where {F,A1,A2} =
    Position{F,promote_type(A1,A2)}
Base.convert(::Type{Position{F,A}}, x::Position{F,A}) where {F,A} = x
Base.convert(::Type{Position{F,A}}, x::Position{F,<:Real}) where {F,A} =
    Position{F,A}(convert(A, x.amount))

Base.:+(p1::Position{F}, p2::Position{F}) where {F} = Position(p1.instrument, p1.amount + p2.amount)
Base.:-(p1::Position{F}, p2::Position{F}) where {F} = Position(p1.instrument,p1.amount - p2.amount)

Base.:/(p1::Position, p2::Position) = p1.amount / p2.amount
Base.:/(p::Position{F}, k::Real) where {F} = Position(p.instrument, p.amount / k)

Base.:*(k::Real, p::Position) = Position(p.instrument, p.amount * k)
Base.:*(p::Position, k::Real) = k * p

Base.:*(val, inst::AbstractInstrument) = Position(inst,val)
Base.:*(inst::AbstractInstrument, val::Real) = Position(inst,val)

Base.show(io::IO, inst::AbstractInstrument) = print(io, symbol(inst))
Base.show(io::IO, ::MIME"text/plain", inst::AbstractInstrument) = print(io, symbol(inst))

Base.show(io::IO, p::Position) = print(io, p.amount, p.instrument)
Base.show(io::IO, ::MIME"text/plain", p::Position) = print(io, p.amount, p.instrument)

Base.zero(::Type{Position{F,A}}) where {F,A} = Position{F,A}(zero(A))
Base.one(::Type{Position{F,A}}) where {F,A} = Position{F,A}(one(A))

end # module Positions